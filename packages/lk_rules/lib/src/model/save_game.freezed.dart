// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SaveGame {
  int get saveVersion;
  String get missionId;
  String get contentHash;
  int get seed;
  List<GameAction> get actions;

  /// Create a copy of SaveGame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SaveGameCopyWith<SaveGame> get copyWith =>
      _$SaveGameCopyWithImpl<SaveGame>(this as SaveGame, _$identity);

  /// Serializes this SaveGame to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as SaveGame;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SaveGame &&
            (identical(other.saveVersion, _this.saveVersion) ||
                other.saveVersion == _this.saveVersion) &&
            (identical(other.missionId, _this.missionId) ||
                other.missionId == _this.missionId) &&
            (identical(other.contentHash, _this.contentHash) ||
                other.contentHash == _this.contentHash) &&
            (identical(other.seed, _this.seed) || other.seed == _this.seed) &&
            const DeepCollectionEquality().equals(
              other.actions,
              _this.actions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as SaveGame;
    return Object.hash(
      runtimeType,
      _this.saveVersion,
      _this.missionId,
      _this.contentHash,
      _this.seed,
      const DeepCollectionEquality().hash(_this.actions),
    );
  }

  @override
  String toString() {
    final _this = this as SaveGame;
    return 'SaveGame(saveVersion: ${_this.saveVersion}, missionId: ${_this.missionId}, contentHash: ${_this.contentHash}, seed: ${_this.seed}, actions: ${_this.actions})';
  }
}

/// @nodoc
abstract mixin class $SaveGameCopyWith<$Res> {
  factory $SaveGameCopyWith(SaveGame value, $Res Function(SaveGame) _then) =
      _$SaveGameCopyWithImpl;
  @useResult
  $Res call({
    int saveVersion,
    String missionId,
    String contentHash,
    int seed,
    List<GameAction> actions,
  });
}

/// @nodoc
class _$SaveGameCopyWithImpl<$Res> implements $SaveGameCopyWith<$Res> {
  _$SaveGameCopyWithImpl(this._self, this._then);

  final SaveGame _self;
  final $Res Function(SaveGame) _then;

  /// Create a copy of SaveGame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? saveVersion = null,
    Object? missionId = null,
    Object? contentHash = null,
    Object? seed = null,
    Object? actions = null,
  }) {
    return _then(
      SaveGame(
        saveVersion: null == saveVersion
            ? _self.saveVersion
            : saveVersion // ignore: cast_nullable_to_non_nullable
                  as int,
        missionId: null == missionId
            ? _self.missionId
            : missionId // ignore: cast_nullable_to_non_nullable
                  as String,
        contentHash: null == contentHash
            ? _self.contentHash
            : contentHash // ignore: cast_nullable_to_non_nullable
                  as String,
        seed: null == seed
            ? _self.seed
            : seed // ignore: cast_nullable_to_non_nullable
                  as int,
        actions: null == actions
            ? _self.actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<GameAction>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [SaveGame].
extension SaveGamePatterns on SaveGame {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SaveGame value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SaveGame() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SaveGame value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SaveGame():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SaveGame value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SaveGame() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int saveVersion,
      String missionId,
      String contentHash,
      int seed,
      List<GameAction> actions,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SaveGame() when $default != null:
        return $default(
          _that.saveVersion,
          _that.missionId,
          _that.contentHash,
          _that.seed,
          _that.actions,
        );
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int saveVersion,
      String missionId,
      String contentHash,
      int seed,
      List<GameAction> actions,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SaveGame():
        return $default(
          _that.saveVersion,
          _that.missionId,
          _that.contentHash,
          _that.seed,
          _that.actions,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int saveVersion,
      String missionId,
      String contentHash,
      int seed,
      List<GameAction> actions,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SaveGame() when $default != null:
        return $default(
          _that.saveVersion,
          _that.missionId,
          _that.contentHash,
          _that.seed,
          _that.actions,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SaveGame implements SaveGame {
  const _SaveGame({
    this.saveVersion = SaveGame.currentVersion,
    required this.missionId,
    required this.contentHash,
    required this.seed,
    required List<GameAction> actions,
  }) : _actions = actions;
  factory _SaveGame.fromJson(Map<String, dynamic> json) =>
      _$SaveGameFromJson(json);

  @override
  @JsonKey()
  final int saveVersion;
  @override
  final String missionId;
  @override
  final String contentHash;
  @override
  final int seed;
  final List<GameAction> _actions;
  @override
  List<GameAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  /// Create a copy of SaveGame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SaveGameCopyWith<_SaveGame> get copyWith =>
      __$SaveGameCopyWithImpl<_SaveGame>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SaveGameToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SaveGame &&
            (identical(other.saveVersion, saveVersion) ||
                other.saveVersion == saveVersion) &&
            (identical(other.missionId, missionId) ||
                other.missionId == missionId) &&
            (identical(other.contentHash, contentHash) ||
                other.contentHash == contentHash) &&
            (identical(other.seed, seed) || other.seed == seed) &&
            const DeepCollectionEquality().equals(other.actions, _actions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      saveVersion,
      missionId,
      contentHash,
      seed,
      const DeepCollectionEquality().hash(_actions),
    );
  }

  @override
  String toString() {
    return 'SaveGame(saveVersion: $saveVersion, missionId: $missionId, contentHash: $contentHash, seed: $seed, actions: $actions)';
  }
}

/// @nodoc
abstract mixin class _$SaveGameCopyWith<$Res>
    implements $SaveGameCopyWith<$Res> {
  factory _$SaveGameCopyWith(_SaveGame value, $Res Function(_SaveGame) _then) =
      __$SaveGameCopyWithImpl;
  @override
  @useResult
  $Res call({
    int saveVersion,
    String missionId,
    String contentHash,
    int seed,
    List<GameAction> actions,
  });
}

/// @nodoc
class __$SaveGameCopyWithImpl<$Res> implements _$SaveGameCopyWith<$Res> {
  __$SaveGameCopyWithImpl(this._self, this._then);

  final _SaveGame _self;
  final $Res Function(_SaveGame) _then;

  /// Create a copy of SaveGame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? saveVersion = null,
    Object? missionId = null,
    Object? contentHash = null,
    Object? seed = null,
    Object? actions = null,
  }) {
    return _then(
      _SaveGame(
        saveVersion: null == saveVersion
            ? _self.saveVersion
            : saveVersion // ignore: cast_nullable_to_non_nullable
                  as int,
        missionId: null == missionId
            ? _self.missionId
            : missionId // ignore: cast_nullable_to_non_nullable
                  as String,
        contentHash: null == contentHash
            ? _self.contentHash
            : contentHash // ignore: cast_nullable_to_non_nullable
                  as String,
        seed: null == seed
            ? _self.seed
            : seed // ignore: cast_nullable_to_non_nullable
                  as int,
        actions: null == actions
            ? _self._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<GameAction>,
      ),
    );
  }
}
