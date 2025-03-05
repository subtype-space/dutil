// dutil - a simple wraper for managing Docker and Docker Compose!

use std::env;
use std::process;


fn usage() {
    println!("usage: dutil [reload|rebuild|networks|ps|psg] [container name]");
    println!("  net|network|networks\n\t\t Returns the list of docker networks");
    println!("  ps|psg\n\t\t If given a container name, perform a search for it. psg performs a grep instead against docker ps -a");
    println!("  rebuild\n\t\t Performs a docker compose down, build, and up in detatched mode");
    println!("  reload\n\t\t Performs a docker compose down, and up, detatched");
    println!("   shell\n\t\t Runs docker exec -it against a given container name and opens a bash (if applicable) shell. Fallsback to use /bin/sh");
    process::exit(1);
}


fn main() {
    // Get arguments
    let args: Vec<String> = env::args().collect();


    if args.len() < 2 {
        usage();
    }
}
