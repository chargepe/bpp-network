#!/bin/bash

#Required packages list as below.
package_list=("docker" "docker-compose" "nginx" "certbot" "jq")

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Redirect input from /dev/null to silence prompts
export DEBIAN_FRONTEND=noninteractive
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1


#Install Package
install_package(){
    if [ -x "$(command -v apt-get)" ]; then
        # APT (Debian/Ubuntu)
        echo "Installing $1"
        sudo apt-get update >/dev/null 2>&1
        sudo apt-get install -y $1 >/dev/null 2>&1
    elif [ -x "$(command -v yum)" ]; then
        # YUM (Red Hat/CentOS)
        echo "Installing $1"
        sudo yum install -y $1 >/dev/null 2>&1
    elif [ -x "$(command -v amazon-linux-extras)" ]; then
        # Amazon Linux 2
        echo "Installing $1"
        sudo amazon-linux-extras install $1 >/dev/null 2>&1
    else
        echo "${RED}Unsupported package manager. Please install $1 manually.${NC}"
        exit 1
    fi
}

remove_package(){
    if [ -x "$(command -v apt-get)" ]; then
        # APT (Debian/Ubuntu)
        sudo apt-get purge -y $1  >/dev/null 2>&1
        sudo apt autoremove -y  >/dev/null 2>&1
    elif [ -x "$(command -v yum)" ]; then
        # YUM (Red Hat/CentOS)
        sudo yum remove -y $1  >/dev/null 2>&1
        sudo yum autoremove -y >/dev/null 2>&1
    fi
}

# Function to install Docker
install_docker_bash() {
    # Check if Docker install
    if [ $? -eq 0 ]; then
        sleep 10
        sudo systemctl enable docker.service
        sudo systemctl restart docker.service
        sudo usermod -a -G docker $USER
    fi

    # Install Docker Bash completion
    if [ -f /etc/bash_completion.d/docker ]; then
        echo "Docker Bash completion is already installed."
    else
        # Install Docker Bash completion
        echo "Installing Docker Bash completion..."
        sudo curl -L https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker -o /etc/bash_completion.d/docker
    fi
}

# Function to install Docker Compose
install_docker_compose() {
    command_exists docker-compose
    if [ $? -eq 0 ]; then
        echo "docker-compose is already installed."
        return
    else
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    # Check if Docker Compose installation was successful
    if [ $? -eq 0 ]; then
        echo "Docker Compose installed successfully."
    else
        echo "Failed to install Docker Compose. Exiting."
        exit 1
    fi

    if [ -f /etc/bash_completion.d/docker-compose ]; then
        echo "Docker Compose Bash completion is already installed."
    else
        # Install Docker Compose Bash completion
        echo "Installing Docker Compose Bash completion..."
        sudo curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
    fi
}


# Check if package is already installed

for package in "${package_list[@]}"; do
    if ! command_exists "node"; then
        install_package "$package"
    fi
    if [ "$package" == "docker" ]; then
        install_docker_bash
    fi
    if [ "$package" == "docker-compose" ]; then
        install_docker_compose
    fi
done

