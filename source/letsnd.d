import base;

struct LetSnd {
    char _let;
    JSound _snd;

    void playSnd() {
        _snd.playSnd;
    }

    auto isPlaying() {
        return _snd.isPlaying;
    }
}