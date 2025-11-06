#!/bin/bash

set -e

is_dry_run() {
    false
}

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

ask_path() {
    reply="$2"
    ask "$@"
    declare -g $reply="$(realpath "${!reply}")"
}

create_new_repo() {
    group_padded="$(pad_with_zeros "$group")"
    if [[ -z $(get_full_names_for_repo_team) ]]; then
        echo "Skipping empty group $group_padded"
        return
    fi
    echo "Creating group $group_padded"
    repo_name="$repo_prefix$group_padded"
    repo_path="$tmp_directory/$repo_name"
    git clone -q "$template_repository" "$repo_path"
    pushd "$repo_path" > /dev/null
    do_replacements "SWAGroup"
    do_replacements "SWA Group "
    do_replacements "$repo_prefix"
    if [[ -n "$(git status --porcelain)" ]]; then
        # working directory not clean -- something changed
        git add .
        git commit --amend --no-edit -q
    fi
    create_github_repo
    add_tutors_team_to_repo
    create_github_repo_team
    add_repo_team_to_repo
    get_users_for_repo_team | add_users_to_repo_team
    git remote add github "$repo_url"
    if is_dry_run; then
        echo Pushing to "$repo_url"
    else
        git push -q github HEAD
    fi
    popd > /dev/null
}

create_github_repo() {
    response="$(github_request POST "orgs/$target_organization/repos" <<EOF
        {
            "name": "$repo_name",
            "description": "SWA Group $group_padded",
            "private": true
        }
EOF
)"
    repo_url="$(jq -r .html_url <<<"$response")"
    repo_owner="$(jq -r .owner.login <<<"$response")"
}

add_team_to_repo() {
    team_slug="$1"
    permission="$2"
    github_request PUT "orgs/$target_organization/teams/$team_slug/repos/$repo_owner/$repo_name" <<EOF
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

get_full_names_for_repo_team() {
    sed -nr "s/^([^\t]+)\t([^\t]+)\t.*\tGruppe $group_padded\t$/\2 \1/p" $groups_file
}

get_users_for_repo_team() {
    get_full_names_for_repo_team | while read full_name; do
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

do_replacements() {
    replacement_text="$1"
    source="$replacement_text[0-9]+"
    destination="$replacement_text$group_padded"
    replace_in_paths "$source" "$destination"
    replace_in_content "$source" "$destination"
}

replace_in_paths() {
    source="$1"
    destination="$2"
    while true; do
        source_path="$(find | grep -P "$source" | head -n 1)"
        if [[ -z "$source_path" ]]; then
            break
        fi
        destination_path="$(sed -r "s/$source/$destination/g" <<<"$source_path")"
        if [[ "$source_path" == "$destination_path" ]]; then
            break
        fi
        mv "$source_path" "$destination_path"
    done
}

replace_in_content() {
    source="$1"
    destination="$2"
    find . \( -type d -name .git -prune \) -o -type f -print0 \
        | xargs -0 sed -i -r "s/$source/$destination/g"
}

pad_with_zeros() {
    number="$1"
    group_count_digit_count="${#group_count}"
    printf %0${group_count_digit_count}d $number
}

github_request() {
    request_type="$1"
    api_path="$2"
    if is_dry_run; then
        echo "$request_type $api_path" > /dev/stderr
        cat > /dev/stderr
        cat <<EOF
            {
                "id": 42,
                "slug": "$current_yyyy-$next_yy-swa-group-$group_padded",
                "html_url": "https://github.com/$target_organization/$repo_name",
                "owner": {
                    "login": "owner-username"
                }
            }
EOF
    else
        curl --no-progress-meter --location \
            --request "$request_type" \
            --url "https://api.github.com/$api_path" \
            --header "Accept: application/vnd.github+json" \
            --header "Authorization: Bearer $github_token" \
            --header "X-GitHub-Api-Version: 2022-11-28" \
            --data @-
    fi
}

current_yy="$(date +%y)"
current_yyyy="$(date +%Y)"
next_yy="$((current_yy + 1))"

ask "GitHub organization" target_organization "hpi-swa-teaching"
ask "Repository prefix" repo_prefix "swa$current_yy-$next_yy-group"
ask "GitHub groups team prefix" repo_team_prefix "$current_yyyy/$next_yy SWA Group"
ask "GitHub tutors team slug (name with dashes)" tutors_team_slug "$current_yyyy-$next_yy-swa-tutors"
ask "Group count" group_count
ask_path "Path to template repository" template_repository
ask_path "Path to Moodle groups file" groups_file
ask_path "Path to Moodle GitHub usernames directory" usernames_directory
ask "GitHub token" github_token

tmp_directory="$(mktemp -d)"

for group in $(seq 1 $group_count); do
    create_new_repo
done
echo "Done!"
