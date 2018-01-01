//#I'm not sure about skips
//#not sure on this?!
//#What of this?!
//#should change from alias to function
import base, record;

private:
enum youHaveFinished = `jx.addToHistory("You have finished!");`;

immutable ifCurrentNull = `
        if (! _current) {
            ` ~ youHaveFinished ~ `

            return;}`;

public:

/// Project
struct ProjectEtc {
private:
    size_t _index; /// index
    Word[] _words;
    Word _current;
    ProjectState _state;
    string[] _projectsList;
    string[] _projectsLotList;
    bool _playingCorrect;
    bool _doPlaySndDone; /// At the end, check for if the sound has been played
    bool _allPerfect; /// At the end, play `all perfect` if all correct with out errors
    size_t _sayCorrectIndexNum;
    string _project;
    string _projectsLot;

    ubyte _wrongs;

	Record _sayCorrects,
           _sayInCorrects,
           _sayAllDones,
           _oneHundredPercent;

    Text _popUp;
    string _completeTxt;

    Skip _skip;

    enum Hint {noHint, letters, showWord}
    Hint _hint = Hint.noHint;
public:
    @property auto ref skip() { return _skip; }

    auto projectsLot() { return _projectsLot; }
    void projectsLot(in string projectsLot0) {
        _projectsLot = projectsLot0;
    }
    void project(in string project0) {
        _project = project0;
    }
    auto project() { return _project; }

    auto getWords() {
        import std.algorithm: map;
        import std.array: array;

        return _words.map!(word => word.word).array;
    }

    /// Load sound groups
    void setupSoundSet() {
        string soundLessFolders;

        auto getList(in string folder) {
            import std.algorithm: endsWith, filter;
            import std.file: dirEntries, SpanMode;
            import std.path: buildPath;
            import std.random: randomShuffle;
            import std.string: toLower;

            JSound[] result;
            foreach(string name; dirEntries(buildPath("SoundSets", g_setup.settingsSoundsSet, folder),
                                                SpanMode.shallow)
                                 .filter!(f => f.name.toLower.endsWith(".wav", ".ogg"))) {
                result ~= new JSound(name);
            }
            if (result.length == 0) {
                if (soundLessFolders.length == 0)
                    soundLessFolders = g_setup.settingsSoundsSet ~ ` \/` ~ "\n";
                soundLessFolders ~= folder ~ " has no valid sound files!\n";
            } else
                result.randomShuffle;

            return result;
        }

        _sayCorrects = Record("Correct", getList("Correct"));
        _sayInCorrects = Record("Incorrect", getList("Incorrect"));
        _sayAllDones = Record("All Done", getList("AllDone"));
        _oneHundredPercent = Record("One Hundred Percent", getList("AllPerfect"));

        if (soundLessFolders.length > 0) {
            import std.stdio;

            writeln(soundLessFolders);
            assert(0, "Check folders (see above)..");
        }
    }

    void setup() {
        skip = Skip.no;
        setupSoundSet;

        _popUp = new Text("", g_font, g_fontSize);
        with(_popUp) {
            setColor = Color.White;
            position = Vector2f(0, 800 - g_fontSize * 5);
        }

        import std.algorithm: filter;
        import std.array: array;
        import std.file: dirEntries, isDir, SpanMode;
        import std.path: dirSeparator;
        import std.string: lastIndexOf;

        addHistory("List of project Lots:");
        auto dirs = dirEntries("Projects", SpanMode.shallow).
            filter!(f => f.name.isDir).array;
        _projectsLotList.length = 0;
        foreach(i, dir; dirs) {
            immutable name = dir[dir.lastIndexOf(dirSeparator) + 1 .. $];
            addHistory(i, ". ", name);
            _projectsLotList ~= name;
        }
    }

    /// Default word, check to see if 
    void checkWord(in string input) { //#should change from alias to function
        addHistory(input);
        if (input == currentWord) {
            enum succeedMessage = "Correct!";

            addHistory(succeedMessage);
            _popUp.setString = succeedMessage;
            if (current.wordState == WordState.notUsed) {
                current.wordState = WordState.correct;
            }
            _sayCorrects.next.playSnd;
            next;
            _playingCorrect = true;

            if (done)
                complete;
        } else {
            if (currentWord != "") {
                enum failedMessage = "Nice try.";
                
                addHistory(failedMessage);
                _popUp.setString = failedMessage;
                if (current.wordState == WordState.notUsed) {
                    current.wordState = WordState.wrong;
                }
                _wrongs += 1;
                _sayInCorrects.playSnd.next;
            }
        } 
    }

    void process() {
        if ((_playingCorrect && ! _sayCorrects.isPlaying) || skip == Skip.yes) {
            skip = Skip.no;
            _playingCorrect = false;
            if (_doPlaySndDone) {
                _doPlaySndDone = false;
                if (_allPerfect)
                    _oneHundredPercent.playSnd.next;
                else
                    _sayAllDones.playSnd.next;
                _popUp.setString = _completeTxt;
            } else {
                if (skip == Skip.no)
                    playWordSound;
            }
        }
    }

    void reset() {
        import std.algorithm: each;

        _wrongs = 0;
        _words.each!(a => a.reset);
        shuffle;
    }

    auto wordCount() { return _words.length; }

    void loadDirNames() {
        import std.algorithm: filter;
        import std.array: array;
        import std.path: dirSeparator, buildPath;
        import std.string: lastIndexOf;

        auto mainColour = jx.historyColour;
        scope(exit)
            jx.historyColour = mainColour;
		jx.historyColour = Color(0, 180, 0);
        _projectsList.length = 0;
        foreach(i, dir; getDirs(buildPath("Projects", _projectsLot))) {
            _projectsList ~= dir[dir.lastIndexOf(dirSeparator) + 1 .. $];
        }
    }
    
    auto dirFromNumName(in int select) {
        if (select >= 0 && select < _projectsList.length) {
            addAllWordsAndStuff(_projectsList[select]);

            return true;
        }
        else {
            addHistory("out of bounds! - it's from 0-", _projectsList.length - 1);
            return false;
        }
    }

    void getProjectsLotByNum(in int i) {
        _projectsLot = _projectsLotList[i];
        g_setup.settingsProjectLot = _projectsLot;
    }

    void addAllWordsAndStuff(in string project) {
        import std.file: dirEntries, SpanMode, isDir, exists;
        import std.algorithm: filter, endsWith;
        import std.path: buildPath, stripExtension, baseName;
        import std.string: toLower;

        _words.length = 0;
        foreach(string name; dirEntries(buildPath("Projects", _projectsLot, project), SpanMode.shallow).
                                filter!(f => f.name.toLower.endsWith(".wav", ".ogg") ||
                                    f.name.isDir)) {
            if (name.isDir) {
                string mainName = buildPath(name, name.baseName ~ ".wav"),
                    hint = buildPath(name, "hint.wav");
                if (! mainName.exists) {
                    (mainName ~ " not found").gh;
                    continue;
                }
                if (hint.exists)
                    _words ~= new Word(mainName, hint);
                else
                    _words ~= new Word(mainName);

            } else
                _words ~= new Word(name);
        }
        g_setup.settingsProject = project;
        _project = project;
    }

    void start() {
        reset;
        _index = 0;
        _current = _words[_index];
        _state = ProjectState.going;
        _hint = Hint.noHint;
        playWordSound;
    }

    auto currentWord() {
        mixin(ifCurrentNull[0 .. $ - 2] ~ ` ""; }`); // return ""; instead of just return;

        return _current.word;
    }

    void playHint() {
        if (_current.hintSnd && ! _current.hintSnd.isPlaying)
            _current.playHint;
    }

    /// Hear the word
    void playWordSound() {
        mixin(ifCurrentNull);

        _current.sfx.playSnd;
        import std.conv: text;

        immutable spellWord = text("(", _index + 1, "/", _words.length, ") Spell the word you heard (press 1 to hear again)..");

        addHistory(spellWord);
        _popUp.setString = spellWord;
    }

    /// Show the word
    void showTheWord() {
        mixin(ifCurrentNull);
        
        _hint += 1;
        if (_hint == Hint.max + 1)
            _hint = Hint.letters;
        string wordHint;
        final switch(_hint) with(Hint) {
            case noHint:
            break;
            case letters:
                import std.random: randomShuffle;
                import std.conv: to;

                auto shuffle = _current.word.to!(dchar[]);
                shuffle.randomShuffle;
                wordHint = "The word has letters: " ~ shuffle.to!string;
            break;
            case showWord: 
                wordHint = "The word is spelt: " ~ _current.word;
            break;
        }
        addHistory(wordHint);
        _popUp.setString = wordHint;
    }

    /// Clear the pop up status
    void clearPopUp() {
        if (_state != ProjectState.finished) {
            _popUp.setString = "";
            _hint = Hint.letters;
        }
    }

    /// return current word
    auto current() {
        return _current;
    }

    /// Check to see if there's a current word
    auto done() {
        return !_current;
    }

    ref auto next() {
        final switch(_state) {
            case ProjectState.going:
                if (skip == Skip.yes) {
                    _current.wordState = WordState.skipped;
                }
                _index += 1;
                if (_index == _words.length) {
                    addHistory("Done.");
                    _current = null;
                    _state = ProjectState.finished;
                } else {
                    addHistory("Next");
                    _current = _words[_index];
                    _hint = Hint.noHint;
                }
            break;
            case ProjectState.finished:
                //#What of this?!
                //complete; // had no effect
            break;
        }

        return this;
    }

    void complete() {
        _doPlaySndDone = true;

        import std.algorithm: count;

        float getCount(WordState wordState) {
            return _words.count!(a => a.wordState == wordState);
        }

        immutable float
            correct = getCount(WordState.correct),
            wrong = getCount(WordState.wrong),
            wrongs = _wrongs,
            skips = getCount(WordState.skipped),
            total = wordCount;

        import std.conv: text;
        import std.format: format;

        _completeTxt = text(total, " total, ", correct, " correct, ", wrong, " wrong",
            ", ", format("%3.0f", (100 / (total == skips ? 1 : total - skips)) * correct), "%, ",
            wrongs, " Errors, ", skips, " skips.");
        _popUp.setString = _completeTxt;

        if (total == correct && skips != total)
            _allPerfect = true;
        else
            _allPerfect = false;
        addHistory(_completeTxt);
        reset;
    }

    void shuffle() {
        import std.random: randomShuffle;

        _words.randomShuffle;
    }

    void draw() {
        g_window.draw(_popUp);
    }
}
