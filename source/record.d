import base;

version(safe) {
@safe:
}

struct Record {
    string _title; // maybe future
    JSound[] _snds;
    size_t _idx;

    auto isPlaying() {
        return _snds[_idx].playing;
    }

    ref auto playSnd() {
        _snds[_idx].play;
        //Mix_PlayChannel(-1, _snds[_idx].mSnd, 0);

        return this;
    }

    ref auto next() {
        _idx += 1;
        if (_idx == _snds.length)
            _idx = 0;

        return this;
    }
}