import base;

class Word {
private:
    string _word;
    JSound _sfx, _hint;

    WordState _wordState;
public:
    @property {
        auto word() { return _word; }
        void word(in string word0) { _word = word0; }

        auto sfx() { return _sfx; }
        void sfx(JSound sfx0) { _sfx = sfx0; }

        auto hintSnd() { return _hint; }

        auto wordState() { return _wordState; }
        void wordState(WordState wordState0) { _wordState = wordState0; }

        auto isHint() { return _hint !is null; }
    }

    this(in string fileName, in string hintFileName = "") {
        import std.path: baseName, stripExtension;
        import std.file: exists;

        if (! fileName.exists) {
            import std.stdio : writeln;

            writeln(fileName, " not found");
            return;
        }

        word = fileName.baseName.stripExtension;
        sfx = new JSound(fileName);
        if (hintFileName != "")
            _hint = new JSound(hintFileName);
        
        reset;
    }

    void playHint() {
        if (isHint)
            _hint.playSnd;
    }

    void reset() {
        wordState = WordState.notUsed;
    }
}
