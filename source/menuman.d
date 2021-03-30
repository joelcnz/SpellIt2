//#very pretty!

version(safe) {
@safe:
}

import base, menu;

struct MenuMan {
    Menu _main;
    Menu _going;
    MenuList _list; /// show list for current word, or just exit button
    Menu _projectList;
    Menu _projectLotList;
    Menu _projectWords;
    Menu _soundSet;
	Menu _alphabetSounds;

    int choose(N)(int min, N nmax, in string title) {
		import std.conv: to;

		int max = nmax.to!int;
        int result = -1;
        
        foreach(i; min .. max + 1) {
            //if (Keyboard.isKeyPressed(cast(Keyboard.Key)(Keyboard.Key.Num0 + i))) {
			//#very pretty!
			if ((g_keys[SDL_SCANCODE_0].keyPressed && i == 0) ||
				(g_keys[SDL_SCANCODE_1].keyPressed && i == 1) ||
				(g_keys[SDL_SCANCODE_2].keyPressed && i == 2) ||
				(g_keys[SDL_SCANCODE_3].keyPressed && i == 3) ||
				(g_keys[SDL_SCANCODE_4].keyPressed && i == 4) ||
				(g_keys[SDL_SCANCODE_5].keyPressed && i == 5) ||
				(g_keys[SDL_SCANCODE_6].keyPressed && i == 6) ||
				(g_keys[SDL_SCANCODE_7].keyPressed && i == 7) ||
				(g_keys[SDL_SCANCODE_8].keyPressed && i == 8) ||
				(g_keys[SDL_SCANCODE_9].keyPressed && i == 9)) {
				keyHold(SDL_SCANCODE_0);
				keyHold(SDL_SCANCODE_1);
				keyHold(SDL_SCANCODE_2);
				keyHold(SDL_SCANCODE_3);
				keyHold(SDL_SCANCODE_4);
				keyHold(SDL_SCANCODE_5);
				keyHold(SDL_SCANCODE_6);
				keyHold(SDL_SCANCODE_7);
				keyHold(SDL_SCANCODE_8);
				keyHold(SDL_SCANCODE_9);
                result = i;
				addHistory(title, ` \/`);
				addHistory(i, " selected");
                break;
            }
        }

        if (result != -1)
			keyHold(SDL_SCANCODE_0 + result);

        return result;
    }

	/// set or update menus
    void updateAll(in string project, in string projectLot, in string soundSet,
				   in string[] projectList, in string alphabetSet) {
        updateMain(project, projectLot, soundSet, alphabetSet);
        updateProjectWords(project, projectList);
        updateGoing(MenuList.yes);
        updateProjectList(project, projectLot);
		updateProjectLots(projectLot);
		doSoundSets;
		doAlphabet;
    }

    void updateMain(in string project, in string projectsLot, in string soundSet, in string alphabetSet) {
        auto items = ["1. Play project",
					  "2. Show project words",
			 	 	  "3. Choose project (" ~ project ~ ")",
			 	 	  "4. Choose projects set (" ~ projectsLot ~ ")",
			 	 	  "5. Choose sound set (" ~ soundSet ~ ")",
					  "6. Choose alphabet set (" ~ alphabetSet ~ ")",
					  "*7. Choose Text Font",
			 	 	  "8. Exit",
					  "  ", // see items.count
					  "*not in yet)"];
        import std.conv: text;
		import std.algorithm: count;
		import std.ascii: isDigit;

        _main = Menu("Welcome to Spell It, - Main Menu -",
            items,
            text("Press a number 1 to ", items.count!(a => a[0].isDigit || a[1].isDigit), " to continue"));
		addHistory("Projects Lot: ", projectsLot, ", Project: ", project);
    }

    void updateProjectWords(in string currentProject, in string[] list) {
		import std.conv: text;

        _projectWords = Menu(text("- Project Words - (", currentProject, ")"), list, "Press 0 to continue");
    }

	void updateGoing(MenuList list) {
        _list = list;

		string[] itemsList;
		string footer;

		final switch(list) with(MenuList) {
			case yes:
				itemsList = ["1. Read out word",
							 "2. Show the word (hint)",
							 "3. Clear pop up",
							 "4. Say the letters",
							 "5. Skip to next word",
							 "6. Tell hint (if any)",
		 					 "7. Exit back to Main Menu"];
                import std.conv: text;

				footer = text("Spell the word then press enter, or press a number 1 to ", itemsList.length);
			break;
			case no:
				itemsList = ["0. Exit back to Main Menu"];
				footer = "All Done, press 0 to continue.";
			break;
		}
		_going = Menu("- Going Menu -",
					  itemsList,
					  footer);
	}

    void updateProjectList(in string currentProject, in string projectPath) {
        import std.path: buildPath, dirSeparator;

		auto dirs = getDirs(buildPath("Projects", projectPath));
		import std.conv: text, to;
        import std.string: lastIndexOf;

		auto items = ["0 to cancel"];
		foreach(i, dir; dirs) {
			items ~= text(i + 1, ". ", dir[dir.lastIndexOf(dirSeparator) + 1 .. $]);
		}
		import std.conv: text;

		_projectList = Menu(text("- Project List - (", currentProject, ")"), items,
			text("Select Project by press a number 1 to ", dirs.length, ", 0 to cancel"));
    }

	void updateProjectLots(in string currentLot) {
		auto dirs = getDirs("Projects");
		import std.conv: text;
		import std.string: lastIndexOf;
		import std.path: dirSeparator;

		string[] items;
		foreach(i, dir; dirs) {
			items ~= text(i + 1, ". ", dir[dir.lastIndexOf(dirSeparator) + 1 .. $]);
		}
		import std.conv: text;

		_projectLotList = Menu(text("- Projects Lot List - (", currentLot, ")"),
			items,
			text("Select Project Lot by Press a number 1 to ", dirs.length, ", 0 to cancel"));
	}

	void doSoundSets() {
		import std.conv: text, to;
		import std.string: lastIndexOf;
		import std.path: dirSeparator;

		auto items = ["0 to cancel"];
		auto dirs = getDirs("SoundSets");
		foreach(i, dir; dirs) {
			items ~= text(i + 1, ". ", dir[dir.lastIndexOf(dirSeparator) + 1 .. $]);
		}
		
		_soundSet = Menu("- Sound Set List -", items, 
			text("Select Sound Set by pressing a number 1 to ", dirs.length, ", 0 to cancel"));
	}

	void doAlphabet() {
		import std.conv: text, to;
		import std.string: lastIndexOf;
		import std.path: dirSeparator;

		auto items = ["0 to cancel"];
		auto dirs = getDirs("Abc");
		foreach(i, dir; dirs) {
			items ~= text(i + 1, ". ", dir[dir.lastIndexOf(dirSeparator) + 1 .. $]);
		}
		
		_alphabetSounds = Menu("- Alphabet Set List -", items, 
			text("Select Sound Set by pressing a number 1 to ", dirs.length, ", 0 to cancel"));
	}
}
