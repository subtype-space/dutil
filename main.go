package main

import (
	"fmt"
	"os"
	"os/exec"
)

var (
	Version = "dev"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(1)
	}

	cmd := os.Args[1]
	arg := ""
	if len(os.Args) > 2 {
		arg = os.Args[2]
	}

	switch cmd {
	case "-v", "--version", "version":
		fmt.Println(Version)
		return
	case "cmd", "command":
		command(arg, os.Args[3:]...)
	case "down":
		runCompose(arg, "down")
	case "log", "logs":
		log(arg)
	case "net", "network", "networks":
		network()
	case "ps", "psg":
		runPS(arg)
	case "pull":
		pull(arg)
	case "rebuild":
		rebuild(arg)
	case "reload":
		reload(arg)
	case "shell", "sh", "bash":
		shell(arg)
	case "up":
		runCompose(arg, "up")
	case "upd":
		runCompose(arg, "upd")
	case "upgrade":
		upgrade(arg)
	default:
		fmt.Fprintf(os.Stderr, "unknown command: %s\n", cmd)
		usage()
		os.Exit(1)
	}
}

func log(container string) {
	if container == "" {
		fmt.Fprintf(os.Stderr, "no container name\n")
		return
	}
	run("docker", "logs", "-f", container)
}

func network() {
	run("docker", "network", "ls")
}

func pull(file string) {
	requireComposePlugin()
	args := []string{"compose"}
	if file != "" {
		args = append(args, "-f", file)
	}
	run("docker", append(args, "pull")...)
}

func rebuild(file string) {
	requireComposePlugin()
	args := []string{"compose"}
	if file != "" {
		args = append(args, "-f", file)
	}
	run("docker", append(args, "build")...)
	run("docker", append(args, "down")...)
	run("docker", append(args, "up", "-d")...)
}

func reload(file string) {
	requireComposePlugin()
	args := []string{"compose"}
	if file != "" {
		args = append(args, "-f", file)
	}
	run("docker", append(args, "down")...)
	run("docker", append(args, "up", "-d")...)
}

func runCompose(file, subcmd string) {
	requireComposePlugin()
	args := []string{"compose"}
	if file != "" {
		args = append(args, "-f", file)
	}
	if subcmd == "upd" {
		run("docker", append(args, "up", "-d")...)
	} else {
		run("docker", append(args, subcmd)...)
	}
}

func runPS(filter string) {
	args := []string{"ps", "-a"}
	if filter != "" {
		args = append(args, "-f", "name="+filter)
	}
	run("docker", args...)
}

func command(container string, cmd ...string) {
	if container == "" {
		fmt.Fprintf(os.Stderr, "no container name\n")
		return
	}
	run("docker", "exec", "-d", container, cmd...)
}

func shell(container string) {
	if container == "" {
		fmt.Fprintf(os.Stderr, "no container name\n")
		return
	}

	if exec.Command("docker", "exec", container, "/bin/bash", "-c", "exit").Run() == nil {
		fmt.Fprintf(os.Stdout, "starting bash shell in %s...\n", container)
		run("docker", "exec", "-it", container, "/bin/bash")
		return
	}

	if exec.Command("docker", "exec", container, "/bin/sh", "-c", "exit").Run() == nil {
		fmt.Fprintf(os.Stdout, "%s: /bin/bash not found, falling back to /bin/sh\n", container)
		run("docker", "exec", "-it", container, "/bin/sh")
		return
	}

	fmt.Fprintf(os.Stderr, "unable to spawn shell in %s\n", container)
}

func upgrade(file string) {
	requireComposePlugin()
	args := []string{"compose"}
	if file != "" {
		args = append(args, "-f", file)
	}
	run("docker", append(args, "pull")...)
	run("docker", append(args, "down")...)
	run("docker", append(args, "up", "-d")...)
}

// requireComposePlugin exits gracefully if the docker compose v2 plugin
// isn't installed, since these commands don't support the legacy
// docker-compose v1 binary.
func requireComposePlugin() {
	if err := exec.Command("docker", "compose", "version").Run(); err != nil {
		fmt.Fprintf(os.Stderr, "docker compose (v2 plugin) not found; install it to use this command\n")
		os.Exit(1)
	}
}

// run executes a command, wiring its stdout/stderr directly to the terminal
// and exits with the same code if it fails
func run(name string, args ...string) {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			os.Exit(exitErr.ExitCode())
		}
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Print(`usage: dutil <command> [file|container]

commands:
  cmd|command <name> [args]		run a command in a container (detached)
  down [file]       			docker compose down
  log|logs <name>   			follow logs for a container
  net|network       			list docker networks
  ps [name]         			list containers, optionally filtered by name
  pull [file]       			docker compose pull
  rebuild [file]    			docker compose build, down, up -d
  reload [file]     			docker compose down, up -d
  shell <name>      			open a shell in a container (/bin/bash with /bin/sh fallback)
  up [file]         			docker compose up (attached)
  upd [file]        			docker compose up -d (detached)
  upgrade [file]    			pull, down, up -d
`)
}
