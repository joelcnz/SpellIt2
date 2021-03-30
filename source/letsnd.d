//#not work
import base;

version(safe) {
@safe:
}

struct LetSnd {
    char _let;
    JSound _snd;

    this(in char let, in string fileName) {
        _let = let;
        _snd = JSound(fileName);
        import std.file : exists;
        assert(fileName);
        // _snd.load(fileName);
        _snd.single = true;
    }

    void playSnd() {
        _snd.play;
        //Mix_PlayChannel(-1, _snd.mSnd, 0);
    }

    auto isPlaying() {
        return _snd.playing;
    }
}
