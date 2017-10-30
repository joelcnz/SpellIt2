import base;

struct Menu {
private:
    string _header;
    string[] _items;
    string _footer;

    Text _text;
public:
    auto items() { return _items; }

    this(in string header, in string[] items, in string footer) {
        set(header, items, footer);
    }

    void set(in string header, in string[] items, in string footer) {
        import std.conv : to;

        _header = header;
        _items = items.dup;
        _footer = footer;

        _text = new Text("", g_font, g_fontSize);
    }

    void view() {
        assert(_text !is null && g_font !is null);

        void draw(in string text, in Vector2f pos, in Color colour) {
            import std.conv : to;

            _text.setString = text.to!dstring;
            _text.position = pos;
            _text.setColor = colour;
            g_window.draw(_text);
        }

        draw(_header, Vector2f(0, 0), Color(0, 255, 0)); // draw header
        int y = g_fontSize * 2;
        void drawListItem(in string line) {
            draw(line, Vector2f(0, y += g_fontSize), Color(255, 180, 0));
        }
        import std.algorithm : each;
        _items.each!drawListItem; // draw options

        draw(_footer, Vector2f(0, y + g_fontSize * 3), Color(0, 255, 0)); // draw footer
    }
}
