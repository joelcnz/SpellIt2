/+
//#load this, even if we don't want a sound played for each letter (have it in that case for sound the word out)

bugs:

Fixed bugs:
Crashed after I put some thing in after completing a project! fixed: was checking the default word with the current word when current was null from finishing the current project


Welcome to Spell-It

Started: 14 March 2017
+/
module main;

import std.math;

import base, menuman;

int main(string[] args) {
	if (g_setup.setup != 0) {
		gh("Aborting...");
		g_window.close;

		return -2;
	}

	if (args.length > 1) {
		import std.string: join;
		import std.range: replicate;

		addHistory("User Name: ", args[1 .. $].join(" "), " ", "#".replicate(10));
	} else {
		addHistory("Must enter a name.. (eg ./spellit Joel Ezra Christensen)");

		return -3;
	}
	
	import letsndpros, std.path;

	LetSndPros letSndPros;
	//#load this, even if we don't want a sound played for each letter (have it in that case for sound the word out)
	letSndPros = LetSndPros(buildPath("Abc", /* temp magic value */ "April17"));
	//auto letSndPros = LetSndPros(buildPath("Abc", /* temp magic value */ "April17Jade")); // 'p' is not said, she says she's not going to say that'

	enum Stage {main, list, go, ProjectSelect, ProjectLotsSelect, SoundSetSelect}
	Stage stage = Stage.main;

	import std.conv: to, text;
	import std.path: buildPath;

	ProjectEtc projectEtc;
	with(projectEtc) {
		with(g_setup) {
			setSettingsFileName = "main.ini";
			loadSettings;
			projectsLot = settingsProjectLot;
			add(settingsProject);
		}
		setup;
		loadDirNames;
	}
	scope(exit) {
		g_setup.saveSettings;
	}

	auto menuMan = MenuMan();
	menuMan.updateAll(g_setup.settingsProject, projectEtc.projectsLot, g_setup.settingsSoundsSet,
					  projectEtc.getWords);

	bool doDisplay = true;

	void setProject() {
		menuMan.updateMain(projectEtc.project, projectEtc.projectsLot, g_setup.settingsSoundsSet);
		menuMan.updateProjectWords(projectEtc.project, projectEtc.getWords);
		menuMan.updateProjectList(projectEtc.project, projectEtc.projectsLot);
	}

    while(g_window.isOpen()) {
        Event event;

        while(g_window.pollEvent(event)) {
            if(event.type == event.EventType.Closed) {
                g_window.close();
            }
        }

		if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
			Keyboard.isKeyPressed(Keyboard.Key.Q)) {
			g_window.close;
		}

		projectEtc.process;

		g_window.clear;

		final switch(stage) {
			case Stage.main:
				menuMan._main.view;
				final switch(menuMan.choose(1, 6)) {
					case -1, 0: break;
					case 1:
						stage = Stage.go;
						projectEtc.start;
					break;
					case 2:
						stage = Stage.list;
					break;
					case 3:
						stage = Stage.ProjectSelect;
					break;
					case 4:
						stage = Stage.ProjectLotsSelect;
					break;
					case 5:
						stage = Stage.SoundSetSelect;
					break;
					case 6:
						g_window.close;
					break;
				}
			break;
			case Stage.list:
				with(menuMan._projectWords) {
					view;
					if (menuMan.choose(0, 0) == 0)
						stage = Stage.main;
				}
			break;
			case Stage.go:
				menuMan._going.view;
				jx.process;
				char choiceLetter;
				bool skipDraw = false;

				if (jx.backSpaceHit) {
					if (g_keySounds)
						letSndPros._backSpace.playSnd;
					jx.backSpaceHit = false;
				}

				void reset() {
					jx.textStr = "";
					jx.xpos = 0;
					jx.updateMeasure;
					jx.enterPressed = false;
				}

				if (jx.textStr.length > 0) {

					void removeLetter() {
						import std.algorithm;
						import std.ascii;
						import std.array;

						jx.textStr = jx.textStr.filter!(a => ! a.isDigit).array;
						jx.xpos = jx.xpos - 1;
						jx.updateMeasure;
						jx.enterPressed = false;
						skipDraw = true;
					}
					import std.ascii: toLower, isAlpha;

					if (g_keySounds && jx.lastKeyPressed.isAlpha) {
						letSndPros._letSnds[jx.lastKeyPressed.to!char.toLower].playSnd;
						jx.lastKeyPressed = ' ';
					}
					import std.regex: matchFirst, regex;

					auto test = jx.textStr.to!string.matchFirst(regex("[0-9]"));
					if (! test.empty) {
						choiceLetter = test.hit[0];
						removeLetter;
					}
					if (jx.enterPressed) {
						immutable input = jx.textStr.to!string;
						projectEtc.checkWord(input);
						if (projectEtc.done) {
							menuMan.updateGoing(MenuList.no);
						}
						reset;
					}
				}
				if (! skipDraw)
					jx.draw;
				projectEtc.draw;

				void doExit() {
					while(Keyboard.isKeyPressed(cast(Keyboard.Key)(Keyboard.Key.Num0 + 6))) { rest; }
					while(Keyboard.isKeyPressed(cast(Keyboard.Key)(Keyboard.Key.Num0 + 0))) { rest; }
					menuMan.updateGoing(MenuList.yes); // put it back as it was
					stage = Stage.main;
				}
				switch(choiceLetter) {
					default: break;
					case '0':
						if (menuMan._list == MenuList.no)
							doExit;
					break;
					case '1':
						projectEtc.playWordSound;
					break;
					case '2':
						projectEtc.showTheWord;
					break;
					case '3':
						projectEtc.clearPopUp;
					break;
					case '4':
						letSndPros.soundTheWordsOut(projectEtc.currentWord);
					break;
					case '5':
						projectEtc.skip = Skip.yes;
						projectEtc.next.playWordSound;
						if (projectEtc.done) {
							projectEtc.complete;
							menuMan.updateGoing(MenuList.no);
						}
					break;
					case '6':
						if (menuMan._list == MenuList.yes)
							doExit;
					break;
				}
			break;
			case Stage.ProjectSelect:
				menuMan._projectList.view;
				import std.conv: to;
				immutable i = menuMan.choose(0, menuMan._projectList.items.length);
				switch(i) {
					default: break;
					case 0:
						stage = Stage.main;
					break;
					case 1: .. case 9:
						if (projectEtc.dirFromNumName(i - 1)) {
							setProject;
							stage = Stage.main;
						}
					break;
				}
			break;
			case Stage.ProjectLotsSelect:
				menuMan._projectLotList.view;
				immutable i = menuMan.choose(0, menuMan._projectList.items.length);
				switch(i) {
					default: break;
					case 0:
						stage = Stage.main;
					break;
					case 1: .. case 9:
						auto lastProjectLot = projectEtc.projectsLot;
						projectEtc.getProjectsLotByNum(i - 1);
						projectEtc.loadDirNames;
						menuMan.updateProjectLots(projectEtc.projectsLot);
						if (lastProjectLot != projectEtc.projectsLot) {
							projectEtc.dirFromNumName(0);
							setProject;
						}
						menuMan.updateProjectList(projectEtc.project, projectEtc.projectsLot);
						menuMan.updateMain(projectEtc.project, projectEtc.projectsLot, g_setup.settingsSoundsSet);
						stage = Stage.main;
					break;
				}
			break;
			case Stage.SoundSetSelect:
				menuMan._soundSet.view;
				import std.conv: to;

				immutable i = menuMan.choose(0, menuMan._soundSet.items.length);
				switch(i) {
					default: break;
					case 0:
						stage = Stage.main;
					break;
					case 1: .. case 9:
						import std.algorithm: filter;
						import std.array: array;
						import std.file: dirEntries, SpanMode;
						import std.path: buildPath, dirSeparator, isDir;
						import std.string: lastIndexOf;
	
						foreach(i2, dir; getDirs("SoundSets"))
							if (i2 == i - 1)
								g_setup.settingsSoundsSet = dir[dir.lastIndexOf(dirSeparator) + 1 .. $];
						projectEtc.setupSoundSet;
						menuMan.updateMain(projectEtc.project, projectEtc.projectsLot, g_setup.settingsSoundsSet);
						stage = Stage.main;
					break;
				}
			break;
		}

		if (doDisplay)
			g_window.display;
 		else
			doDisplay = true;
    } // while

	return 0;
}
