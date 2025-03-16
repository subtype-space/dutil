package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}

	// Check if docker compose is installed
	if _, err := exec.Command("docker", "compose", "version").CombinedOutput(); err != nil {
		fmt.Println("Docker compose v2 is not installed")
		os.Exit(1)
	}

	command := os.Args[1]
	switch command {
	case "net", "network", "networks":
		runCommand("docker", "network", "ls")

	case "ps":
		if len(os.Args) < 3 {
			runCommand("docker", "ps", "-a")
		} else {
			containerName := os.Args[2]
			runCommand("docker", "ps", "-a", "-f", "name="+containerName)
		}

	case "psg":
		if len(os.Args) < 3 {
			runCommand("docker", "ps", "-a")
		} else {
			searchTerm := os.Args[2]
			output, err := exec.Command("docker", "ps", "-a").Output()
			if err != nil {
				fmt.Println("Error:", err)
				os.Exit(1)
			}
			
			lines := strings.Split(string(output), "\n")
			for _, line := range lines {
				if strings.Contains(line, searchTerm) {
					fmt.Println(line)
				}
			}
		}

	case "rebuild":
		runCommandSequence(
			[]string{"docker", "compose", "down"},
			[]string{"docker", "compose", "build", "."},
			[]string{"docker", "compose", "up", "-d"},
		)

	case "reload":
		composeFile := ""
		if len(os.Args) > 2 {
			composeFile = os.Args[2]
			runCommandSequence(
				[]string{"docker", "compose", "-f", composeFile, "down"},
				[]string{"docker", "compose", "-f", composeFile, "up", "-d"},
			)
		} else {
			runCommandSequence(
				[]string{"docker", "compose", "down"},
				[]string{"docker", "compose", "up", "-d"},
			)
		}

	case "shell":
		if len(os.Args) < 3 {
			usage()
			fmt.Println("Error: Missing container name")
			os.Exit(1)
		}
		
		containerName := os.Args[2]
		// Try bash first
		cmd := exec.Command("docker", "exec", containerName, "/bin/bash")
		if err := cmd.Run(); err == nil {
			fmt.Println("Starting /bin/bash in", containerName)
			runInteractiveCommand("docker", "exec", "-it", containerName, "/bin/bash")
		} else {
			// Try sh as fallback
			cmd = exec.Command("docker", "exec", containerName, "/bin/sh")
			if err := cmd.Run(); err == nil {
				fmt.Println("Warning:", containerName, "does not support /bin/bash, using /bin/sh")
				runInteractiveCommand("docker", "exec", "-it", containerName, "/bin/sh")
			} else {
				fmt.Println("Error: Unable to spawn shell session for", containerName)
				os.Exit(1)
			}
		}

	case "upgrade":
		runCommandSequence(
			[]string{"docker", "compose", "down"},
			[]string{"docker", "compose", "pull"},
			[]string{"docker", "compose", "up", "-d"},
		)
		fmt.Println("Complete")

	default:
		usage()
		os.Exit(2)
	}
}

func usage() {
	fmt.Println("usage: dutil [reload|rebuild|networks|ps|psg] [container name]")
	fmt.Println("  net|network|networks\n\t\t Returns the list of docker networks")
	fmt.Println("  ps|psg\n\t\t If given a container name, perform a search for it. psg performs a grep instead against docker ps -a")
	fmt.Println("  rebuild\n\t\t Performs a docker compose down, build, and up, detatched")
	fmt.Println("  reload\n\t\t Performs a docker compose down and up, detatched")
	fmt.Println("  shell\n\t\t Runs docker exec -it against a given container name and opens a bash shell (as fallback, use /bin/sh).")
	fmt.Println("Part of the _subtype common library")
}

func runCommand(command string, args ...string) {
	cmd := exec.Command(command, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	if err := cmd.Run(); err != nil {
		fmt.Println("Error executing command:", err)
		os.Exit(1)
	}
}

func runInteractiveCommand(command string, args ...string) {
	cmd := exec.Command(command, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	if err := cmd.Run(); err != nil {
		fmt.Println("Error executing interactive command:", err)
		os.Exit(1)
	}
}

func runCommandSequence(commands ...[]string) {
	for _, cmdArgs := range commands {
		cmd := exec.Command(cmdArgs[0], cmdArgs[1:]...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		
		if err := cmd.Run(); err != nil {
			fmt.Println("Error executing command sequence:", err)
			os.Exit(1)
		}
	}
}