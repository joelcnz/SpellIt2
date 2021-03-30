//#dateTimeString - why does this work, when it's not included
//#this did not work (still uses a lot of CPU), except at say 500, which is slow
module base;

version(safe) {
@safe:
}

public:
import dini.dini;
import jecsdl;

import menu, projectetc, setup, worditem;

Setup g_setup;
string g_accountDir;

alias jx = g_inputJex;

enum MenuList {yes, no}
enum Skip {yes, no}

enum ProjectState {going, finished}
enum WordState {notUsed, wrong, correct, skipped} // if you get one wrong, then it can't become right

immutable g_fontSize = 30;

void addHistory(T...)(T args) {
    import std.file: append;
    import std.path: buildPath;
    import std.conv: text;

    //#dateTimeString - why does this work, when it's not included    
    import jmisc: jm_upDateStatus;

	jm_upDateStatus(args);
    append(buildPath("Accounts", g_accountDir, "history.txt"), text(dateTimeString, " ", args, "\n"));
}

//#this did not work (still uses a lot of CPU), except at say 500, which is slow
void rest(int count = 50) {
    while(count > 0) {
        //Handle events on queue
        while( SDL_PollEvent( &gEvent ) != 0 ) {
            //User requests quit
            if (gEvent.type == SDL_QUIT)
                count = -1;
        }

        SDL_PumpEvents();

		if ((g_keys[SDL_SCANCODE_LGUI].keyPressed ||
                g_keys[SDL_SCANCODE_RGUI].keyPressed) &&
                g_keys[SDL_SCANCODE_Q].keyInput)
			break;

        SDL_Delay(1); //count.dur!"msecs");
        count -= 1;
    }
}

void keyHold(uint key) {
    //while(Keyboard.isKeyPressed(cast(Keyboard.Key)key)) { rest; }
    while(g_keys[key].keyPressed) {
        SDL_PumpEvents();
        rest;
    }
}

immutable g_keySounds = true;

auto getDirs(in string folder) {
    import std.algorithm: filter;
    import std.array: array;
    import std.file: dirEntries, isDir, SpanMode;

    return dirEntries(folder, SpanMode.shallow).filter!(f => f.name.isDir).array;
}
