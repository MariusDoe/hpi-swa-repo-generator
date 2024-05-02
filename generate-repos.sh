#!/bin/bash

set -e

ask() {
    prompt="$1"
    reply="$2"
    default="$3"
    default_display=""
    if [[ -n "$default" ]]; then
        default_display=" [$default]"
    fi
    echo -n "$prompt$default_display: "
    read "$reply"
    if [[ -z "${!reply}" ]]; then
        declare -g $reply="$default"
    fi
}

assign_repo() {
    group_padded="$(pad_with_zeros "$group")"
    repo_name="$(get_repo_name_for_group)"
    if [[ -z $repo_name ]]; then
        echo "Skipping group $group_padded"
        return 0
    fi
    echo "Assigning group $group_padded"
    add_tutors_team_to_repo
    create_github_repo_team
    add_repo_team_to_repo
    get_users_for_repo_team | add_users_to_repo_team
}

add_team_to_repo() {
    team_slug="$1"
    permission="$2"
    github_request PUT "orgs/$target_organization/teams/$team_slug/repos/$target_organization/$repo_name" > /dev/null <<EOF
        {
            "permission": "$permission"
        }
EOF
}

add_tutors_team_to_repo() {
    add_team_to_repo "$tutors_team_slug" "maintain"
}

create_github_repo_team() {
    repo_team_slug="$((github_request POST "orgs/$target_organization/teams" <<EOF
        {
            "name": "$repo_team_prefix $group_padded",
            "privacy": "closed"
        }
EOF
) | jq -r .slug)"
}

add_repo_team_to_repo() {
    add_team_to_repo "$repo_team_slug" "push"
}

add_users_to_repo_team() {
    while read username; do
        github_request PUT "orgs/$target_organization/teams/$repo_team_slug/memberships/$username" < /dev/null > /dev/null
    done
}

get_repo_name_for_group() {
    awk "NR==$group" "$repos_file"
}

get_users_for_repo_team() {
    sed -nr "s/^([^\t]+)\t([^\t]+)\t.*\tGroup $group_padded\t$/\2 \1/p" $groups_file \
        | while read full_name; do
            path="$(echo "$usernames_directory/${full_name}_"*"/onlinetext.html")"
            if [[ -f $path ]]; then
                submission="$(lynx --dump "$path" | xargs)" # xargs to trim
                regular_name_regex='^@?[a-zA-Z0-9-]+$'
                github_url_regex='^https://github\.com/[a-zA-Z0-9-]+$'
                if [[ "$submission" =~ $regular_name_regex ]]; then
                    echo "${submission#@}"
                elif [[ "$submission" =~ $github_url_regex ]]; then
                    echo "${submission#https://github.com/}"
                else
                    echo "Student $full_name from group $group_padded submitted an unparsable GitHub username: $submission" > /dev/stderr
                fi
            else
                echo "Student $full_name from group $group_padded did not submit their GitHub username" > /dev/stderr
            fi
        done
}

pad_with_zeros() {
    number="$1"
    group_count_digit_count="${#group_count}"
    printf %0${group_count_digit_count}d $number
}

github_request() {
    request_type="$1"
    api_path="$2"
    curl --no-progress-meter --location \
        --request "$request_type" \
        --url "https://api.github.com/$api_path" \
        --header "Accept: application/vnd.github+json" \
        --header "Authorization: Bearer $github_token" \
        --header "X-GitHub-Api-Version: 2022-11-28" \
        --data @-
    # for debug purposes
#     echo "$request_type $api_path" > /dev/stderr
#     cat > /dev/stderr
#     cat <<EOF
#         {
#             "id": 42,
#             "slug": "$current_yyyy-swt-group-$group_padded",
#             "owner": {
#                 "login": "owner-username"
#             }
#         }
# EOF
}

current_yyyy="$(date +%Y)"

ask "GitHub organization" target_organization "hpi-swa-teaching"
ask "GitHub groups team prefix" repo_team_prefix "$current_yyyy SWT Group"
ask "GitHub tutors team slug (name with dashes)" tutors_team_slug "$current_yyyy-tutors"
ask "Group count" group_count
ask "Path to repos list file" repos_file
ask "Path to Moodle groups file" groups_file
ask "Path to Moodle GitHub usernames directory" usernames_directory
ask "GitHub token" github_token

tmp_directory="$(mktemp -d)"

for group in $(seq 1 $group_count); do
    assign_repo
done
echo "Done!"
