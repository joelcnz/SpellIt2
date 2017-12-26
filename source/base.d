//#dateTimeString - why does this work, when it's not included
//#this did not work (still uses a lot of CPU), except at say 500, which is slow
module base;

public:
import dsfml.audio;
import dsfml.graphics;
import dsfml.window;

import dini.dini, jec;

import menu, projectetc, setup, worditem;

Setup g_setup;
string g_accountDir;

alias jx = g_inputJex;

enum MenuList {yes, no}
enum Skip {yes, no}

enum ProjectState {going, finished}
enum WordState {notUsed, wrong, correct, skipped} // if you get one wrong, then it can't become right

immutable g_fontSize = 40;

void addHistory(T...)(T args) {
    import std.file: append;
    import std.path: buildPath;
    import std.conv: text;

    //#dateTimeString - why does this work, when it's not included    
    import jmisc: upDateStatus;

	upDateStatus(args);
    append(buildPath("Accounts", g_accountDir, "history.txt"), text(dateTimeString, " ", args, "\n"));
}

//#this did not work (still uses a lot of CPU), except at say 500, which is slow
void rest(int count = 50) {
    sleep(count.dur!"msecs");
}

void keyHold(int key) {
    while(Keyboard.isKeyPressed(cast(Keyboard.Key)key)) { rest; }
}

immutable g_keySounds = true;

auto getDirs(in string folder) {
    import std.algorithm: filter;
    import std.array: array;
    import std.file: dirEntries, isDir, SpanMode;

    return dirEntries(folder, SpanMode.shallow).filter!(f => f.name.isDir).array;
}
