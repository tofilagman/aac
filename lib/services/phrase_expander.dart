class PhraseExpander {
  // Verbs that can follow want/like (activity verbs)
  static const _activityVerbs = {
    'eat', 'drink', 'play', 'read', 'draw', 'sleep', 'swim',
    'run', 'jump', 'paint', 'sing', 'bath', 'watch tv',
    'open', 'close', 'go',
  };

  // Verbs that take an infinitive after them
  static const _wantVerbs = {'want', 'need', 'like', 'love', 'hate'};

  // Places where "go" needs no preposition at all: go home, go outside
  static const _placesNoPrep = {'home', 'outside', 'car'};

  // Places that work with bare "to" (no article): go to school
  static const _placesNoArticle = {'school', 'hospital', 'church'};

  // Places that need "to the": go to the park
  static const _placesWithArticle = {
    'park', 'store', 'bathroom', 'bedroom', 'kitchen',
  };

  // Feeling adjectives that need "feel" after "I"
  static const _feelings = {
    'happy', 'sad', 'angry', 'scared', 'tired', 'excited',
    'surprised', 'bored', 'silly', 'okay', 'hurt',
  };

  // Countable nouns → article to prepend
  static const _countable = {
    'apple': 'an',
    'banana': 'a',
    'egg': 'an',
    'cookie': 'a',
    'candy': 'some',
    'pizza': 'a',
    'ice cream': 'some',
    'chicken': 'some',
  };

  // Words that already act as determiners (no article needed after these)
  static const _determiners = {
    'a', 'an', 'the', 'some', 'my', 'your', 'his', 'her',
    'our', 'their', 'this', 'that', 'any', 'more', 'to',
  };

  static String expand(List<String> labels) {
    if (labels.isEmpty) return '';
    if (labels.length == 1) return _cap(labels[0]);

    final tokens = labels.map((l) => l.toLowerCase().trim()).toList();
    final out = <String>[];

    for (int i = 0; i < tokens.length; i++) {
      final tok = tokens[i];
      final next = i + 1 < tokens.length ? tokens[i + 1] : null;
      final prevOut = out.isNotEmpty ? out.last.toLowerCase() : null;

      // "not like" + activity verb → "do not like to [verb]"
      if (tok == 'not like' && next != null && _activityVerbs.contains(next)) {
        out.add('do not like');
        out.add('to');
        continue;
      }

      // "not like" alone → "do not like"
      if (tok == 'not like') {
        out.add('do not like');
        continue;
      }

      // "I" directly before a feeling → insert "feel"
      if (tok == 'i' && next != null && _feelings.contains(next)) {
        out.add(labels[i]);
        out.add('feel');
        continue;
      }

      // want/like/love + activity verb (incl. go) → insert "to"
      if (_wantVerbs.contains(tok) && next != null && _activityVerbs.contains(next)) {
        out.add(labels[i]);
        out.add('to');
        continue;
      }

      // "go" + place (no preposition needed): go home, go outside
      if (tok == 'go' && next != null && _placesNoPrep.contains(next)) {
        out.add(labels[i]);
        continue;
      }

      // "go" + place (no article) → "go to [place]"
      if (tok == 'go' && next != null && _placesNoArticle.contains(next)) {
        out.add(labels[i]);
        out.add('to');
        continue;
      }

      // "go" + place (with article) → "go to the [place]"
      if (tok == 'go' && next != null && _placesWithArticle.contains(next)) {
        out.add(labels[i]);
        out.add('to');
        out.add('the');
        continue;
      }

      // Insert article before countable nouns if not already preceded by a determiner
      if (_countable.containsKey(tok) &&
          (prevOut == null || !_determiners.contains(prevOut))) {
        out.add(_countable[tok]!);
      }

      out.add(labels[i]);
    }

    if (out.isEmpty) return '';
    out[0] = _cap(out[0]);
    return out.join(' ');
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
