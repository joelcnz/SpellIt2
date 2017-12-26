module setup;

import base;

/// Main setup struct
static struct Setup {
private:
    string _settingsFileName;

    string _settingsSoundsSet;
    string _settingsProjectLot;
    string _settingsProject;
    string _alphabetSet;
    string _settingsFont;

    int _settingsReadOutPausesMilSecs;
public:
    auto settingsSoundsSet() { return _settingsSoundsSet; }
    void settingsSoundsSet(in string soundsSet) { _settingsSoundsSet = soundsSet; }

    auto settingsProjectLot() { return _settingsProjectLot; }
    void settingsProjectLot(in string projectLot) { _settingsProjectLot = projectLot; }

    auto settingsProject() { return _settingsProject; }
    void settingsProject(in string project) { _settingsProject = project; }

    auto alphabetSet() { return _alphabetSet; }
    void alphabetSet(in string alphabetSet) { _alphabetSet = alphabetSet; }

    auto settingsReadOutPausesMilSecs() { return _settingsReadOutPausesMilSecs; }

    void setSettingsFileName(in string fileName) {
        _settingsFileName = fileName;
    }

    auto settingsFont() { return _settingsFont; }
    void settingsFont(in string font) {
        import std.path: buildPath;
        import std.file: exists;

        if (buildPath("Fonts", font).exists) {
            _settingsFont = font;
        } else {
            import std.stdio: writeln;

            writeln(font, " - not exist!");
        }
    }

    bool fileNameExists() {
        import std.file: exists;

        return exists(_settingsFileName);
    }

    void saveSettings() {
        import std.stdio: File;

        auto file = File(_settingsFileName, "w");

        with(file) {
            writeln("[settings]");
            writefln("soundsSet=%s", _settingsSoundsSet);
            writefln("projectLot=%s", _settingsProjectLot);
            writefln("project=%s", _settingsProject);
            writefln("alphabetSet=%s", _alphabetSet);
            writefln("font=%s", _settingsFont);
            writefln("readOutPausesMilSecs=%s", _settingsReadOutPausesMilSecs);
        }
    }

    void loadSettings() {
        if (fileNameExists) {
            import std.conv: to;

            auto ini = Ini.Parse(_settingsFileName);

            _settingsSoundsSet = ini["settings"].getKey("soundsSet");
            _settingsProjectLot = ini["settings"].getKey("projectLot");
            _settingsProject = ini["settings"].getKey("project");
            _alphabetSet = ini["settings"].getKey("alphabetSet");
            settingsFont = ini["settings"].getKey("font");
            _settingsReadOutPausesMilSecs = ini["settings"].getKey("readOutPausesMilSecs").to!int;
        } else {
            import std.stdio: stderr, writeln;

            stderr.writeln(_settingsFileName, " - not found");
        }
    }

    int setup() {
        import std.stdio: writeln;

        writeln("Spell It - Setup started");

        import std.path: buildPath;

        immutable WELCOME = "Welcome to Spell-It! Press [System] + [Q] to quit";
        g_window = new RenderWindow(VideoMode.getDesktopMode, WELCOME);

        import jec.setup : setup;

        g_font = new Font;
        g_font.loadFromFile(buildPath("Fonts", g_setup.settingsFont));
        if (! g_font) {
            import std.stdio: writeln;

            writeln("Font not load");
            return -2;
        }

        g_checkPoints = true;
        if (int retVal = jec.setup != 0) {
            import std.stdio: writefln;

            writefln("File: %s, Error function: %s, Line: %s, Return value: %s", __FILE__, __FUNCTION__, __LINE__, retVal);
            return -1;
        }

        //immutable size = 100, lower = 40;
        immutable size = g_fontSize, lower = g_fontSize / 2;
        jx = new InputJex(/* position */ Vector2f(0, g_window.getSize.y - size - lower),
                        /* font size */ size,
                        /* header */ "Word: ",
                        /* Type (oneLine, or history) */ InputType.history);
        jx.setColour(Color(255, 200, 0));
        jx.addToHistory(""d);
        jx.edge = false;

        g_mode = Mode.edit;
    	g_terminal = true;

        jx.addToHistory(WELCOME);
        jx.showHistory = false;
        g_window.setFramerateLimit(60);

        writeln("Spell It - Setup finished");

        return 0;
    }
}
