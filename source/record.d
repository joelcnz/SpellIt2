import base;

struct Record {
    string _title; // maybe future
    JSound[] _snds;
    size_t _idx;

    auto isPlaying() {
        return _snds[_idx].isPlaying;
    }

    ref auto playSnd() {
        _snds[_idx].playSnd;

        return this;
    }

    ref auto next() {
        _idx += 1;
        if (_idx == _snds.length)
            _idx = 0;

        return this;
    }
}