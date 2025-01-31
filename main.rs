use std::fs;
use std::fs::ReadDir;
use std::env;

fn grep(paths: ReadDir, target: &str) {
    for path in paths {
	let current: String = path
	    .unwrap()
	    .path()
	    .display()
	    .to_string();	
	
	let subdir: Result<ReadDir, _> = fs::read_dir(format!("{}", &current));
	
	if subdir.is_err() {
	    let contents: Result<String, _> = fs::read_to_string(&current);

	    if contents.is_ok() {
		let mut i: u32 = 1;
		for line in contents.unwrap().lines() {
		    if line.contains(target) {
			println!("\x1b[91m{}\x1b[0m:\x1b[92m{}\x1b[0m: {}", current, i, line);
		    }
		    i += 1;
		}
	    }
	    continue;
	}	
	grep(subdir.unwrap(), target);
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    assert_ne!(args.len(), 1);
    
    let paths: Result<ReadDir, _> = fs::read_dir(env::current_dir().unwrap());
    if paths.is_ok() {
	grep(paths.unwrap(), &args[1]);
    }
}
