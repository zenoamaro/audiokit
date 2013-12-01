(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';

    if (has(cache, path)) return cache[path].exports;
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex].exports;
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  var list = function() {
    var result = [];
    for (var item in modules) {
      if (has(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.list = list;
  globals.require.brunch = true;
})();
require.register("app", function(exports, require, module) {
var Keyboard, Master, MonoOsc;

Master = require('components/master');

MonoOsc = require('generators/mono');

Keyboard = require('input/keyboard');

this.ctx = new (typeof AudioContext !== "undefined" && AudioContext !== null ? AudioContext : webkitAudioContext);

this.osc = new MonoOsc(ctx, {
  oscillator: {
    shape: 'triangle',
    octave: -2,
    envelope: {
      attack: .001,
      decay: .1,
      sustain: .2,
      release: .05
    }
  },
  modulation: {
    gain: 40,
    frequency: 6,
    envelope: {
      attack: 2,
      decay: 0,
      sustain: 1,
      release: 1
    }
  }
});

this.master = new Master(ctx);

this.keyboard = new Keyboard;

osc.connect({
  to: master
});

keyboard.connect(osc);
});

;require.register("components/envelope", function(exports, require, module) {
var Component, DECAY_SEEK_TIME, Envelope, KILL_TIME, music, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

music = require('core/music');

Component = require('core/component');

KILL_TIME = .001;

DECAY_SEEK_TIME = .1;

module.exports = Envelope = (function(_super) {
  __extends(Envelope, _super);

  function Envelope() {
    _ref = Envelope.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Envelope.prototype.defaults = {
    attack: .01,
    decay: .01,
    sustain: 1,
    release: .01
  };

  Envelope.prototype.initialize = function() {
    this._connections = [];
    return this.initializeOutputs();
  };

  Envelope.prototype.reset = function(param) {
    var _i, _len, _ref1, _results;
    if (!param) {
      _ref1 = this._connections;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        param = _ref1[_i];
        _results.push(this.reset(param));
      }
      return _results;
    } else {
      this.cancel(param);
      return param.linearRampToValueAtTime(0, this.ctx.currentTime + KILL_TIME);
    }
  };

  Envelope.prototype.cancel = function(param) {
    var now, _i, _len, _ref1, _results;
    if (!param) {
      _ref1 = this._connections;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        param = _ref1[_i];
        _results.push(this.cancel(param));
      }
      return _results;
    } else {
      now = this.ctx.currentTime;
      param.cancelScheduledValues(now);
      return param.setValueAtTime(param.value, now);
    }
  };

  Envelope.prototype.trigger = function(value) {
    var decay_seeker, now, param, _i, _len, _ref1, _results;
    if (value == null) {
      value = true;
    }
    now = this.ctx.currentTime;
    _ref1 = this._connections;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      param = _ref1[_i];
      if (value === true) {
        param.linearRampToValueAtTime(1, now + KILL_TIME + this.options.attack);
        _results.push(param.setTargetAtTime(this.options.sustain, now + KILL_TIME + this.options.attack, this.options.decay * music.EXP_FALL));
      } else if (value === false) {
        this.cancel(param);
        if (param.value > this.options.sustain) {
          decay_seeker = Math.min(this.options.decay, DECAY_SEEK_TIME);
        } else {
          decay_seeker = 0;
        }
        param.setTargetAtTime(this.options.sustain, now, decay_seeker * music.EXP_FALL);
        _results.push(param.setTargetAtTime(0, now + decay_seeker, this.options.release * music.EXP_FALL));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Envelope.prototype.initializeOutputs = function() {
    var _this = this;
    return this.outputs.push({
      id: 'out',
      node: function() {
        return _this.param;
      }
    });
  };

  Envelope.prototype.connect = function(param) {
    this._connections = _.unique(this._connections.concat(param));
    return this.reset(param);
  };

  Envelope.prototype.disconnect = function(param) {
    return this._connections = _.without(this._connections, function(p) {
      return p === param;
    });
  };

  return Envelope;

})(Component);
});

;require.register("components/gain", function(exports, require, module) {
var Component, Gain, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Component = require('core/component');

module.exports = Gain = (function(_super) {
  __extends(Gain, _super);

  function Gain() {
    _ref = Gain.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Gain.prototype.defaults = {
    gain: 1
  };

  Gain.prototype.initialize = function(ctx, options) {
    this.initializeInputs();
    this.initializeOutputs();
    return this._amp = this.ctx.createGain();
  };

  Gain.prototype.update = function() {
    return this._amp.gain.value = this.options.gain;
  };

  Gain.prototype.initializeInputs = function() {
    var _this = this;
    this.inputs.push({
      id: 'in',
      node: function() {
        return _this._amp;
      }
    });
    return this.inputs.push({
      id: 'gain',
      node: function() {
        return _this._amp.gain;
      }
    });
  };

  Gain.prototype.initializeOutputs = function() {
    var _this = this;
    return this.outputs.push({
      id: 'out',
      node: function() {
        return _this._amp;
      }
    });
  };

  return Gain;

})(Component);
});

;require.register("components/master", function(exports, require, module) {
var Gain, Master, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Gain = require('components/gain');

module.exports = Master = (function(_super) {
  __extends(Master, _super);

  function Master() {
    _ref = Master.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Master.prototype.initialize = function() {
    Master.__super__.initialize.apply(this, arguments);
    return this._amp.connect(this.ctx.destination);
  };

  return Master;

})(Gain);
});

;require.register("components/oscillator", function(exports, require, module) {
var Component, Envelope, KILL_TIME, Oscillator, RELEASE_FALL_MUL, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Component = require('core/component');

Envelope = require('components/envelope');

KILL_TIME = .001;

RELEASE_FALL_MUL = 10;

module.exports = Oscillator = (function(_super) {
  __extends(Oscillator, _super);

  function Oscillator() {
    _ref = Oscillator.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Oscillator.prototype.defaults = {
    shape: 'sine',
    gain: 1,
    envelope: {
      attack: .001,
      decay: .1,
      sustain: .2,
      release: .001
    }
  };

  Oscillator.prototype.initialize = function() {
    this.initializeInputs();
    this.initializeOutputs();
    this._out = this.ctx.createGain();
    this._amp = this.ctx.createGain();
    this._mod = this.ctx.createGain();
    this._env = new Envelope(this.ctx);
    this._amp.gain.value = 0;
    this._env.connect(this._amp.gain);
    return this._amp.connect(this._out);
  };

  Oscillator.prototype.startOscillator = function() {
    if (this._osc) {
      clearTimeout(this._oscStopTimer);
    }
    if (!this._osc) {
      this._osc = this.ctx.createOscillator();
      this._osc.connect(this._amp);
      this._mod.connect(this._osc.detune);
      this._osc.start();
    }
    return this._env.reset();
  };

  Oscillator.prototype.stopOscillator = function(release) {
    var stop,
      _this = this;
    if (!this._osc) {
      return;
    }
    stop = function() {
      _this._mod.disconnect(_this._osc.detune);
      _this._osc.disconnect(_this._amp);
      _this._osc.stop();
      return _this._osc = false;
    };
    clearTimeout(this._oscStopTimer);
    return this._oscStopTimer = setTimeout(stop, (release * RELEASE_FALL_MUL) * 1000);
  };

  Oscillator.prototype.trigger = function(state, freq) {
    if (state === true) {
      this.startOscillator();
      this.update();
      this._osc.frequency.setValueAtTime(freq, this.ctx.currentTime + KILL_TIME);
      return this._env.trigger(true);
    } else if (state === false) {
      this._env.trigger(false);
      return this.stopOscillator(this._env.options.release);
    }
  };

  Oscillator.prototype.update = function() {
    var _ref1;
    if ((_ref1 = this._osc) != null) {
      _ref1.type = this.options.shape;
    }
    this._env.set(this.options.envelope);
    return this._out.gain.setValueAtTime(this.options.gain, this.ctx.currentTime);
  };

  Oscillator.prototype.initializeInputs = function() {
    var _this = this;
    this.inputs.push({
      id: 'gain',
      node: function() {
        return _this._amp.gain;
      }
    });
    return this.inputs.push({
      id: 'mod',
      node: function() {
        return _this._mod;
      }
    });
  };

  Oscillator.prototype.initializeOutputs = function() {
    var _this = this;
    return this.outputs.push({
      id: 'out',
      node: function() {
        return _this._out;
      }
    });
  };

  return Oscillator;

})(Component);
});

;require.register("core/class", function(exports, require, module) {
var Class;

module.exports = Class = (function() {
  Class.prototype.defaults = {};

  function Class(options) {
    if (typeof this.initialize === "function") {
      this.initialize();
    }
    this.set(options);
  }

  Class.prototype.set = function(options) {
    return this.options = $.extend(true, {}, this.defaults, this.options, options);
  };

  return Class;

})();
});

;require.register("core/component", function(exports, require, module) {
var Class, Component,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Class = require('core/class');

module.exports = Component = (function(_super) {
  __extends(Component, _super);

  function Component(ctx, options) {
    this.ctx = ctx;
    this.inputs = [];
    this.outputs = [];
    Component.__super__.constructor.call(this, options);
  }

  Component.prototype.input = function(id) {
    if (id == null) {
      id = 'in';
    }
    return _.find(this.inputs, function(input) {
      return input.id === id;
    });
  };

  Component.prototype.output = function(id) {
    if (id == null) {
      id = 'out';
    }
    return _.find(this.outputs, function(output) {
      return output.id === id;
    });
  };

  Component.prototype.connect = function(options) {
    var dest, fromPin, toPin;
    dest = options.to;
    fromPin = this.output(options.fromPin);
    toPin = dest.input(options.toPin);
    return fromPin.node().connect(toPin.node());
  };

  Component.prototype.disconnect = function(options) {
    var dest, fromPin, toPin;
    dest = options.to;
    fromPin = this.output(options.fromPin);
    toPin = dest.input(options.toPin);
    return fromPin.node().disconnect(toPin.node());
  };

  Component.prototype.set = function(options) {
    Component.__super__.set.apply(this, arguments);
    return this.update();
  };

  Component.prototype.update = function() {};

  return Component;

})(Class);
});

;require.register("core/effect", function(exports, require, module) {
var Effect, Gain, Node, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Node = require('core/node');

Gain = require('components/gain');

module.exports = Effect = (function(_super) {
  __extends(Effect, _super);

  function Effect() {
    _ref = Effect.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Effect.prototype.defaults = {
    level: 1,
    gain: 1,
    wet: 1
  };

  Effect.prototype.initialize = function() {
    this.initializeInputs();
    this.initializeOutputs();
    this._in = new Gain(this.ctx);
    return this._out = new Gain(this.ctx);
  };

  Effect.prototype.initializeInputs = function() {
    var _this = this;
    return this.outputs.push({
      id: 'in',
      node: function() {
        return _this._in.input().node();
      }
    });
  };

  Effect.prototype.initializeOutputs = function() {
    var _this = this;
    return this.outputs.push({
      id: 'out',
      node: function() {
        return _this._out.output().node();
      }
    });
  };

  Effect.prototype.update = function() {
    this._in.set({
      gain: this.options.level
    });
    return this._out.set({
      gain: this.options.gain
    });
  };

  return Effect;

})(Node);
});

;require.register("core/generator", function(exports, require, module) {
var Gain, Generator, Node, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Node = require('core/node');

Gain = require('components/gain');

module.exports = Generator = (function(_super) {
  __extends(Generator, _super);

  function Generator() {
    _ref = Generator.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Generator.prototype.defaults = {
    out: {}
  };

  Generator.prototype.initialize = function() {
    this._notes = {};
    this.initializeOutputs();
    return this._out = new Gain(this.ctx);
  };

  Generator.prototype.initializeOutputs = function() {
    var _this = this;
    return this.outputs.push({
      id: 'out',
      node: function() {
        return _this._out.output().node();
      }
    });
  };

  Generator.prototype.update = function() {
    return this._out.set(this.options.out);
  };

  Generator.prototype.trigger = function(note) {};

  return Generator;

})(Node);
});

;require.register("core/music", function(exports, require, module) {
var EXP_FALL, EXP_RISE, K, NOTATION, NOTES, OCTAVE, ROOT, music;

ROOT = 261.63;

OCTAVE = 1200;

K = OCTAVE / (Math.log(2 / Math.LN10));

NOTATION = /(\w#?)(\d+)/;

NOTES = {
  'c': 0,
  'c#': 1,
  'd': 2,
  'd#': 3,
  'e': 4,
  'f': 5,
  'f#': 6,
  'g': 7,
  'g#': 8,
  'a': 9,
  'a#': 10,
  'b': 11
};

EXP_RISE = 63.2 / 100;

EXP_FALL = (100 - 63.2) / 100;

module.exports = music = {
  ROOT: ROOT,
  OCTAVE: OCTAVE,
  EXP_RISE: EXP_RISE,
  EXP_FALL: EXP_FALL,
  note: function(note) {
    var match, octave, _ref;
    if (match = NOTATION.exec(note)) {
      _ref = match, match = _ref[0], note = _ref[1], octave = _ref[2];
      octave = (parseInt(octave, 10)) - 4;
      note = NOTES[note.toLowerCase()];
      return (100 * note) + music.octaves(octave);
    } else {
      return false;
    }
  },
  hz: function(cents) {
    return ROOT * Math.pow(Math.pow(2, 1 / OCTAVE), cents);
  },
  octaves: function(oct) {
    return OCTAVE * oct;
  }
};
});

;require.register("core/node", function(exports, require, module) {
var Component, Node, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Component = require('core/component');

module.exports = Node = (function(_super) {
  __extends(Node, _super);

  function Node() {
    _ref = Node.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  return Node;

})(Component);
});

;require.register("generators/mono", function(exports, require, module) {
var Envelope, Gain, Generator, MonoOsc, Oscillator, music, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

music = require('core/music');

Gain = require('components/gain');

Oscillator = require('components/oscillator');

Envelope = require('components/envelope');

Generator = require('core/generator');

module.exports = MonoOsc = (function(_super) {
  __extends(MonoOsc, _super);

  function MonoOsc() {
    _ref = MonoOsc.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  MonoOsc.prototype.defaults = {
    out: {},
    modulation: {
      shape: 'triangle',
      gain: 0,
      frequency: 10
    },
    oscillator: {
      shape: 'triangle',
      octave: 0,
      tune: 0
    }
  };

  MonoOsc.prototype.initialize = function() {
    return MonoOsc.__super__.initialize.apply(this, arguments);
  };

  MonoOsc.prototype.update = function() {
    var nodes, note, _ref1, _results;
    MonoOsc.__super__.update.apply(this, arguments);
    _ref1 = this._notes;
    _results = [];
    for (note in _ref1) {
      nodes = _ref1[note];
      nodes.osc.set(this.options.oscillator);
      _results.push(nodes.mod.set(this.options.modulation));
    }
    return _results;
  };

  MonoOsc.prototype.frequency = function(note) {
    var cents;
    cents = (music.note(note)) + (music.octaves(this.options.oscillator.octave)) + this.options.oscillator.tune;
    return music.hz(cents);
  };

  MonoOsc.prototype.noteOn = function(note) {
    var mod, osc;
    if (!(note in this._notes)) {
      this._notes[note] = {
        osc: osc = new Oscillator(this.ctx),
        mod: mod = new Oscillator(this.ctx)
      };
      this.update();
      mod.trigger(true, this.options.modulation.frequency);
      osc.trigger(true, this.frequency(note));
      mod.connect({
        to: osc,
        toPin: 'mod'
      });
      return osc.connect({
        to: this._out
      });
    }
  };

  MonoOsc.prototype.noteOff = function(note) {
    var block, mod, osc;
    if (block = this._notes[note]) {
      osc = block.osc, mod = block.mod;
      osc.trigger(false);
      mod.trigger(false);
      return delete this._notes[note];
    }
  };

  MonoOsc.prototype.trigger = function(note, state) {
    if (state === true) {
      return this.noteOn(note);
    } else if (state === false) {
      return this.noteOff(note);
    }
  };

  return MonoOsc;

})(Generator);
});

;require.register("input/keyboard", function(exports, require, module) {
var Class, Keyboard, NOTE_MAP, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Class = require('core/class');

NOTE_MAP = {
  'U+003C': 'b4',
  'U+005A': 'c5',
  'U+0053': 'c#5',
  'U+0058': 'd5',
  'U+0044': 'd#5',
  'U+0043': 'e5',
  'U+0056': 'f5',
  'U+0047': 'f#5',
  'U+0042': 'g5',
  'U+0048': 'g#5',
  'U+004E': 'a5',
  'U+004A': 'a#5',
  'U+004D': 'b5',
  'U+002C': 'c6',
  'U+004C': 'c#6',
  'U+002E': 'd6',
  'U+00F2': 'd#6',
  'U+002D': 'e6',
  'U+0051': 'c6',
  'U+0032': 'c#6',
  'U+0057': 'd6',
  'U+0033': 'd#6',
  'U+0045': 'e6',
  'U+0052': 'f6',
  'U+0035': 'f#6',
  'U+0054': 'g6',
  'U+0036': 'g#6',
  'U+0059': 'a6',
  'U+0037': 'a#6',
  'U+0055': 'b6',
  'U+0049': 'c7',
  'U+0039': 'c#7',
  'U+004F': 'd7',
  'U+0030': 'd#7',
  'U+0050': 'e7',
  'U+00E8': 'f7',
  'U+00EC': 'f#7',
  'U+002B': 'g7'
};

module.exports = Keyboard = (function(_super) {
  __extends(Keyboard, _super);

  function Keyboard() {
    this.onKeyUp = __bind(this.onKeyUp, this);
    this.onKeyDown = __bind(this.onKeyDown, this);
    _ref = Keyboard.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Keyboard.prototype.defaults = {};

  Keyboard.prototype.initialize = function() {
    this._connections = [];
    document.body.addEventListener('keydown', this.onKeyDown);
    return document.body.addEventListener('keyup', this.onKeyUp);
  };

  Keyboard.prototype.connect = function(node) {
    return this._connections = _.unique(this._connections.concat(node));
  };

  Keyboard.prototype.disconnect = function(node) {
    return this._connections = _.without(this._connections, function(p) {
      return p === node;
    });
  };

  Keyboard.prototype.noteFromKeycode = function(keycode) {
    return NOTE_MAP[keycode];
  };

  Keyboard.prototype.trigger = function(note, state) {
    var conn, _i, _len, _ref1, _results;
    _ref1 = this._connections;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      conn = _ref1[_i];
      _results.push(conn.trigger(note, state));
    }
    return _results;
  };

  Keyboard.prototype.onKeyDown = function(event) {
    var note;
    note = this.noteFromKeycode(event.keyIdentifier);
    if (note) {
      this.trigger(note, true);
    }
    return false;
  };

  Keyboard.prototype.onKeyUp = function(event) {
    var note;
    note = this.noteFromKeycode(event.keyIdentifier);
    if (note) {
      this.trigger(note, false);
    }
    return false;
  };

  return Keyboard;

})(Class);
});

;
//# sourceMappingURL=app.js.map