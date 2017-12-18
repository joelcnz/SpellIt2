//#put a pause in here
import base;

import letsnd;

struct LetSndPros {
    LetSnd[char] _letSnds;
    JSound _backSpace;

    this(in string filesLocation) {
        import std.algorithm: each, endsWith, filter;
        import std.array: array;
        import std.ascii: lowercase, digits;
        import std.file: dirEntries, exists, isDir, SpanMode;
        import std.path: dirSeparator, buildPath;
        import std.stdio: writeln;
        import std.string: lastIndexOf, split;

        string fileName;
        auto success = true;
        foreach(let; lowercase) {
            void checkNSet(in string ext) {
                auto candadate = buildPath(filesLocation, let ~ ext);
                if (candadate.exists)
                    fileName = candadate;
            }
            // it will select the second one if it exists (even if the first one exists too)
            ".wav .ogg".split.each!(ext => checkNSet(ext));

            if (fileName.exists) {
                _letSnds[let] = LetSnd(let, new JSound(fileName));
            } else {
                success = false;
                writeln(fileName, " - failed");
            }
        }
        auto root = "backspace";
        string rootPlusExt;
        foreach(ext; ".wav .ogg".split)
            if (buildPath(filesLocation, root ~ ext).exists)
                rootPlusExt = root ~ ext;
        fileName = buildPath(filesLocation, rootPlusExt);
        if (! fileName.exists) {
            writeln(fileName, " - not found");
            success = false;
        }
        else
            _backSpace = new JSound(fileName);

        assert(success, "check your letter sound files");
    }

    void playPause(in char let) {
        assert(let in _letSnds, "Play pause failed!");
        _letSnds[let].playSnd;
        while(_letSnds[let].isPlaying) { rest; }
        rest(g_setup.settingsReadOutPausesMilSecs);
    }

    void soundTheWordsOut(in string word) {
        import std.algorithm: each;
        import std.conv: to;

        word.to!(char[]).each!(a => playPause(a));
    }
}
