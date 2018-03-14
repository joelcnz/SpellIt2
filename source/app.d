/+
//#TO DO
//#don't know what this is here for

bugs:

Fixed bugs:
Crashed after I put some thing in after completing a project! fixed: was checking the default word with the current word when current was null from finishing the current project


Welcome to Spell-It

Started: 14 March 2017

2 12 2017 Started adding custom alphabet sounds (Morris here)
1 12 2017 Added showing where you are upto (eg. 5/11 doing number 5 out of 11 in the project). Worked on word skipping.
+/
module main;

import std.math;
import std.algorithm: filter;
import std.array: array;
import std.file: dirEntries, SpanMode, isDir, exists;
import std.path: buildPath, dirSeparator;
import std.string: lastIndexOf, join;
import std.range: replicate;
import std.conv: to, text;

import base, menuman;

int main(string[] args) {
	scope(exit) {
		import std.stdio : writeln;
		writeln;
		writeln("### ###");
		writeln("#   # #");
		writeln("### ###");
		writeln("  # #  ");
		writeln("### #");
		writeln;
	}
	if (args.length > 1) {
		immutable userName = args[1 .. $].join(" ");
		immutable account = buildPath("Accounts", userName);
		if (account.exists && account.isDir) {
			g_accountDir = userName;
		} else {
			import std.stdio: writeln;

			writeln("Account no found!");

			return -4;
		}
	} else {
		addHistory("Must enter a name.. (eg ./spellit Joel)");

		return -3;
	}
		
	ProjectEtc projectEtc;
	with(projectEtc) {
		with(g_setup) {
			setSettingsFileName = buildPath("Accounts", g_accountDir, "main.ini");
			loadSettings;
			projectsLot = settingsProjectLot;
			addAllWordsAndStuff(settingsProject);
		}
	}

	if (g_setup.setup != 0) {
		gh("Aborting...");
		g_window.close;

		return -2;
	}

	with(projectEtc) {
		setup;
		loadDirNames;
	}
	scope(exit) {
		g_setup.saveSettings;
	}

	enum Stage {main, list, go, projectSelect, projectLotsSelect, soundSetSelect, alphabetSetSelect, textFont}
	Stage stage = Stage.main;

	import letsndpros, std.path;

	LetSndPros letSndPros;
	void setAlphabet() {
		letSndPros = LetSndPros(buildPath("Abc", g_setup.alphabetSet));
	}
	setAlphabet;

	auto menuMan = MenuMan();
	menuMan.updateAll(g_setup.settingsProject, projectEtc.projectsLot, g_setup.settingsSoundsSet,
					  projectEtc.getWords, g_setup.alphabetSet);

	bool doDisplay = true;

	void setProject() {
		menuMan.updateMain(projectEtc.project, projectEtc.projectsLot, g_setup.settingsSoundsSet,
						   g_setup.alphabetSet);
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
				final switch(menuMan.choose(Stage.min + 1, Stage.max + 1, "Main Menu")) {
					case -1, 0: break;
					case 1:
						stage = Stage.go;
						projectEtc.start;
					break;
					case 2:
						stage = Stage.list;
					break;
					case 3:
						stage = Stage.projectSelect;
					break;
					case 4:
						stage = Stage.projectLotsSelect;
					break;
					case 5:
						stage = Stage.soundSetSelect;
					break;
					case 6:
						stage = Stage.alphabetSetSelect;
					break;
					case 7:
						stage = Stage.textFont;
					break;
					case 8:
						g_window.close;
					break;
				}
			break;
			case Stage.list:
				with(menuMan._projectWords) {
					view;
					if (menuMan.choose(0, 0, "Project List") == 0)
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

					void removeDigit() {
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
					import std.algorithm: canFind;

					if (g_keySounds && jx.lastKeyPressed.isAlpha) {
						immutable tkey = jx.lastKeyPressed.to!char.toLower;
						if (tkey in letSndPros._letSnds)
							letSndPros._letSnds[tkey].playSnd;
						jx.lastKeyPressed = ' ';
					}
					import std.regex: matchFirst, regex;

					auto test = jx.textStr.to!string.matchFirst(regex("[0-9]"));
					if (! test.empty) {
						choiceLetter = test.hit[0];
						removeDigit;
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
					keyHold(Keyboard.Key.Num0 + 6);
					keyHold(Keyboard.Key.Num0 + 7);
					keyHold(Keyboard.Key.Num0 + 0); //#don't know what this is here for

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
						addHistory("Play word");
						projectEtc.playWordSound;
					break;
					case '2':
						addHistory("Show hint, or word");
						projectEtc.showTheWord;
					break;
					case '3':
						addHistory("Clear word");
						projectEtc.clearPopUp;
					break;
					case '4':
						addHistory("Sound word out..");
						letSndPros.soundTheWordsOut(projectEtc.currentWord);
					break;
					case '5':
						projectEtc.skip = Skip.yes;
						addHistory("Word skipped..");
						projectEtc.next;
						if (projectEtc.done) {
							menuMan.updateGoing(MenuList.no);
							projectEtc.complete;
						}
						reset;
						keyHold(Keyboard.Key.Num5);
					break;
					case '6':
						addHistory("Play hint..");
						projectEtc.playHint;
					break;
					case '7':
						addHistory("Go to Main menu..");
						if (menuMan._list == MenuList.yes)
							doExit;
					break;
				}
			break;
			case Stage.projectSelect:
				menuMan._projectList.view;

				immutable i = menuMan.choose(0, menuMan._projectList.items.length, "Project Select");
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
			case Stage.projectLotsSelect:
				menuMan._projectLotList.view;
				immutable i = menuMan.choose(0, menuMan._projectLotList.items.length, "Project Lots Select");
				switch(i) {
					default: break;
					case 0:
						stage = Stage.main;
					break;
					case 1: .. case 9:
						if (i >= menuMan._projectList.items.length)
							continue;
						immutable lastProjectLot = projectEtc.projectsLot;
						projectEtc.getProjectsLotByNum(i - 1);
						projectEtc.loadDirNames;
						menuMan.updateProjectLots(projectEtc.projectsLot);
						if (lastProjectLot != projectEtc.projectsLot) {
							projectEtc.dirFromNumName(0);
							setProject;
						}
						menuMan.updateProjectList(projectEtc.project, projectEtc.projectsLot);
						menuMan.updateMain(projectEtc.project, projectEtc.projectsLot,
										   g_setup.settingsSoundsSet, g_setup.alphabetSet);
						stage = Stage.main;
					break;
				}
			break;
			case Stage.soundSetSelect:
				menuMan._soundSet.view;
				import std.conv: to;

				immutable i = menuMan.choose(0, menuMan._soundSet.items.length, "Sound Set Select");
				switch(i) {
					default: break;
					case 0:
						stage = Stage.main;
					break;
					case 1: .. case 9:	
						foreach(i2, dir; getDirs("SoundSets"))
							if (i2 == i - 1)
								g_setup.settingsSoundsSet = dir[dir.lastIndexOf(dirSeparator) + 1 .. $];
						projectEtc.setupSoundSet;
						menuMan.updateMain(projectEtc.project, projectEtc.projectsLot,
										   g_setup.settingsSoundsSet, g_setup.alphabetSet);
						stage = Stage.main;
					break;
				}
			break;
			case Stage.alphabetSetSelect:
				menuMan._alphabetSounds.view;

				immutable i = menuMan.choose(0, menuMan._alphabetSounds.items.length, "Alphabet Set Select");
				switch(i) {
					default: break;
					case 0:
						stage = Stage.main;
					break;
					case 1: .. case 9:
						foreach(i2, dir; getDirs("Abc"))
							if (i2 == i - 1)
								g_setup.alphabetSet = dir[dir.lastIndexOf(dirSeparator) + 1 .. $];
						setAlphabet;
						menuMan.updateMain(projectEtc.project, projectEtc.projectsLot,
										   g_setup.settingsSoundsSet, g_setup.alphabetSet);
						stage = Stage.main;
					break;
				}
			break;
			case Stage.textFont:
				//#TO DO
				stage = Stage.main;
			break;
		}

		if (doDisplay)
			g_window.display;
 		else
			doDisplay = true;
    } // while

	return 0;
}
