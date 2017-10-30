import base;

class Word {
private:
    string _word;
    JSound _sfx;

    WordState _wordState;
public:
    @property {
        auto word() { return _word; }
        void word(in string word0) { _word = word0; }

        auto sfx() { return _sfx; }
        void sfx(JSound sfx0) { _sfx = sfx0; }

        auto wordState() { return _wordState; }
        void wordState(WordState wordState0) { _wordState = wordState0; }
    }

    this(in string fileName) {
        import std.path : baseName, stripExtension;
        import std.file : exists;

        if (! fileName.exists) {
            import std.stdio : writeln;

            writeln(fileName, " not found");
            return;
        }

        word = fileName.baseName.stripExtension;
        sfx = new JSound(fileName);
        
        reset;
    }

    void reset() {
        wordState = WordState.notUsed;
    }
}
