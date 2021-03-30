//#assert

version(safe) {
@safe:
}

import base;

struct Menu {
private:
    string _header;
    string[] _items;
    string _footer;

    JText _text;
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

        //_text = new Text("", g_font, g_fontSize);
		_text = JText("", SDL_Point(0,0), SDL_Color(255,180,0,255), g_fontSize, buildPath("fonts", "DejaVuSans.ttf"));
			// SDL_Rect(0,0), SDL_Color(255,180,0,255), g_fontSize, buildPath("fonts", "DejaVuSans.ttf"));
    }

    void view() {
        //assert(_text !is null && g_font !is null); //#assert

        void draw(in string text, in SDL_Point pos, in SDL_Color colour) {
            import std.conv : to;

            _text.setString = text;
            _text.pos = Point(pos.x,pos.y);
            _text.colour = colour;
            _text.draw(gRenderer);
        }

        draw(_header, SDL_Point(0, 0), SDL_Color(0, 255, 0)); // draw header
        int y = g_fontSize * 2;
        void drawListItem(in string line) {
            draw(line, SDL_Point(0, y += g_fontSize), SDL_Color(255, 180, 0));
        }
        import std.algorithm : each;
        _items.each!drawListItem; // draw options

        draw(_footer, SDL_Point(0, y + g_fontSize * 3), SDL_Color(0, 255, 0)); // draw footer
    }
}
