# GitHub Repository Read Access Script

This Bash script interacts with the **GitHub API** to list users who have **read access** to a given repository.

## Prerequisites
- A **GitHub account**.
- A **GitHub Personal Access Token (PAT)** with `repo` scope for private repositories.
- **jq** installed (for parsing JSON responses). Install it using:
  ```bash
  sudo apt-get install jq   # Debian/Ubuntu
  brew install jq           # macOS
  choco install jq          # Windows (via Chocolatey)
  ```



## Usage
### Running the Script
Execute the script by passing the **repository owner** ie **organizationName** and **repository name** as arguments:
```bash
./script.sh <RepoOwner> <RepoName>
```
Example:
```bash
./script.sh puneeths11 my-repo
```

### Authentication
Ensure you export your **GitHub username** and **personal access token** before running the script:
```bash
export username="your-github-username"
export token="your-github-token"
```

# Making Environment Variables Persistent on EC2

By default, using the `export` command in an EC2 instance only sets environment variables for the current session. Once you log out, the session ends, and the variables are lost. To make them persistent, follow the steps below.

## Solution: Make Environment Variables Persistent

To ensure that the username and token environment variables are available permanently, add them to a shell configuration file that loads every time you log in.

### Option 1: Store Variables in `~/.bashrc` (Recommended)

1. Open the `~/.bashrc` file:
    ```bash
    nano ~/.bashrc
    ```

2. Add the following lines at the bottom of the file:
    ```bash
    export username="xxxxxx"
    export token="xxxxx"
    ```

3. Save and exit by pressing `CTRL + X`, then `Y`, and then `Enter`.

4. Apply the changes immediately:
    ```bash
    source ~/.bashrc
    ```

5. Verify that the environment variables have been set correctly:
    ```bash
    export -p | grep username
    export -p | grep token
    ```

These steps will make sure that your `username` and `token` environment variables persist across sessions.


## How It Works
1. **Fetches repository collaborators** using the GitHub API.
2. **Filters users** with `pull` permissions (read access).
3. **Prints their GitHub usernames**.

## Example Output
```
Listing users with read access to puneeths11/my-repo...
Users with read access to puneeths11/my-repo:
user1
user2
user3
```

## Troubleshooting
- If no users are displayed, ensure:
  - The repository exists.
  - You have permission to view collaborators.
  - The GitHub token has the correct scope (`repo` for private repositories).



This script is written in **Bash**, a Unix shell scripting language. It interacts with the **GitHub API** to list users with **read access** (permissions to pull) to a specific GitHub repository. Here's a detailed breakdown of each part of the script:

### 1. **#!/bin/bash**
- **Meaning**: This is called a "shebang." It specifies that the script should be executed using the **bash** shell, which is common for shell scripting.
- **Explanation**: It tells the operating system to use the **bash** interpreter to run the script.

### 2. **API_URL="https://api.github.com"**
- **Meaning**: This assigns the **GitHub API URL** to the variable `API_URL`.
- **Explanation**: This is the base URL used to make requests to the GitHub API.

### 3. **USERNAME=$username**
- **Meaning**: This assigns the **GitHub username** to the variable `USERNAME`.
- **Explanation**: The variable `username` should be defined earlier (or passed when running the script). It's used for authenticating API requests.

### 4. **TOKEN=$token**
- **Meaning**: This assigns the **personal access token** (GitHub token) to the variable `TOKEN`.
- **Explanation**: The token is used for authentication along with the username to authorize API requests.

### 5. **REPO_OWNER=$1**
- **Meaning**: This assigns the first argument passed to the script (the repository owner's username) to the variable `REPO_OWNER`.
- **Explanation**: `$1` is a positional parameter representing the first argument passed when running the script.

### 6. **REPO_NAME=$2**
- **Meaning**: This assigns the second argument passed to the script (the repository name) to the variable `REPO_NAME`.
- **Explanation**: `$2` is a positional parameter representing the second argument passed to the script.

### 7. **Function to make a GET request to the GitHub API**
- **Meaning**: The following function (`github_api_get`) sends a **GET request** to the GitHub API to fetch information.

```bash
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}
```
- **Explanation**:
  - **`function github_api_get`**: Declares a function named `github_api_get`.
  - **`local endpoint="$1"`**: Defines a local variable `endpoint` and assigns the first argument passed to the function (`$1`), which represents a part of the API URL.
  - **`local url="${API_URL}/${endpoint}"`**: Defines a local variable `url` by concatenating the base API URL (`API_URL`) with the `endpoint`.
  - **`curl -s -u "${USERNAME}:${TOKEN}" "$url"`**: Uses `curl` to send a GET request to the constructed `url` with authentication (`-u` flag with username and token). The `-s` flag silences progress output.

### 8. **Function to list users with read access to the repository**
```bash
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"
    
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}
```
- **`function list_users_with_read_access`**: Declares a function named `list_users_with_read_access`.
- **`local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"`**: Sets the `endpoint` variable to the GitHub API path for fetching repository collaborators.
- **`collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"`**:
  - Calls the `github_api_get` function to get the list of collaborators for the specified repository.
  - Pipes the response to `jq` (a tool for parsing JSON):
    - `'.[]'` iterates over each collaborator.
    - `select(.permissions.pull == true)` filters collaborators who have pull (read) permissions.
    - `.login` extracts the login name of the user.
- **`if [[ -z "$collaborators" ]]; then`**: Checks if the `collaborators` variable is empty (`-z`).
  - If empty, prints "No users with read access found."
  - If not empty, it prints the list of users who have read access.

### 9. **Main script**
```bash
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
```
- **`echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."`**: Prints a message indicating that the script is about to list users with read access.
- **`list_users_with_read_access`**: Calls the function `list_users_with_read_access` to list the users with read access to the specified repository.

---

### Final Flow:
1. **User runs the script**, passing the repository owner and repository name as arguments.
2. **The script makes an authenticated request** to the GitHub API to get the list of collaborators.
3. **The script filters the collaborators** who have read access (pull permissions) and displays their usernames.
4. If no one has read access, the script informs the user that no such users exist.

### Requirements:
- **jq** (for parsing JSON) must be installed.
- **GitHub API token** and **username** must be set correctly for authentication.

This script is useful for managing access control in GitHub repositories, especially for identifying collaborators with specific permissions.

## Author
[Puneeth S](https://github.com/puneeths11)

