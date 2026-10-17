// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Unity {
  int get court;
  int get clan;
  int get people;

  /// Create a copy of Unity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UnityCopyWith<Unity> get copyWith =>
      _$UnityCopyWithImpl<Unity>(this as Unity, _$identity);

  /// Serializes this Unity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as Unity;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Unity &&
            (identical(other.court, _this.court) ||
                other.court == _this.court) &&
            (identical(other.clan, _this.clan) || other.clan == _this.clan) &&
            (identical(other.people, _this.people) ||
                other.people == _this.people));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as Unity;
    return Object.hash(runtimeType, _this.court, _this.clan, _this.people);
  }

  @override
  String toString() {
    final _this = this as Unity;
    return 'Unity(court: ${_this.court}, clan: ${_this.clan}, people: ${_this.people})';
  }
}

/// @nodoc
abstract mixin class $UnityCopyWith<$Res> {
  factory $UnityCopyWith(Unity value, $Res Function(Unity) _then) =
      _$UnityCopyWithImpl;
  @useResult
  $Res call({int court, int clan, int people});
}

/// @nodoc
class _$UnityCopyWithImpl<$Res> implements $UnityCopyWith<$Res> {
  _$UnityCopyWithImpl(this._self, this._then);

  final Unity _self;
  final $Res Function(Unity) _then;

  /// Create a copy of Unity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? court = null,
    Object? clan = null,
    Object? people = null,
  }) {
    return _then(
      Unity(
        court: null == court
            ? _self.court
            : court // ignore: cast_nullable_to_non_nullable
                  as int,
        clan: null == clan
            ? _self.clan
            : clan // ignore: cast_nullable_to_non_nullable
                  as int,
        people: null == people
            ? _self.people
            : people // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Unity].
extension UnityPatterns on Unity {
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
    TResult Function(_Unity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Unity() when $default != null:
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
    TResult Function(_Unity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unity():
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
    TResult? Function(_Unity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unity() when $default != null:
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
    TResult Function(int court, int clan, int people)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Unity() when $default != null:
        return $default(_that.court, _that.clan, _that.people);
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
    TResult Function(int court, int clan, int people) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unity():
        return $default(_that.court, _that.clan, _that.people);
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
    TResult? Function(int court, int clan, int people)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unity() when $default != null:
        return $default(_that.court, _that.clan, _that.people);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Unity extends Unity {
  const _Unity({required this.court, required this.clan, required this.people})
    : super._();
  factory _Unity.fromJson(Map<String, dynamic> json) => _$UnityFromJson(json);

  @override
  final int court;
  @override
  final int clan;
  @override
  final int people;

  /// Create a copy of Unity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UnityCopyWith<_Unity> get copyWith =>
      __$UnityCopyWithImpl<_Unity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UnityToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Unity &&
            (identical(other.court, court) || other.court == court) &&
            (identical(other.clan, clan) || other.clan == clan) &&
            (identical(other.people, people) || other.people == people));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, court, clan, people);
  }

  @override
  String toString() {
    return 'Unity(court: $court, clan: $clan, people: $people)';
  }
}

/// @nodoc
abstract mixin class _$UnityCopyWith<$Res> implements $UnityCopyWith<$Res> {
  factory _$UnityCopyWith(_Unity value, $Res Function(_Unity) _then) =
      __$UnityCopyWithImpl;
  @override
  @useResult
  $Res call({int court, int clan, int people});
}

/// @nodoc
class __$UnityCopyWithImpl<$Res> implements _$UnityCopyWith<$Res> {
  __$UnityCopyWithImpl(this._self, this._then);

  final _Unity _self;
  final $Res Function(_Unity) _then;

  /// Create a copy of Unity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? court = null,
    Object? clan = null,
    Object? people = null,
  }) {
    return _then(
      _Unity(
        court: null == court
            ? _self.court
            : court // ignore: cast_nullable_to_non_nullable
                  as int,
        clan: null == clan
            ? _self.clan
            : clan // ignore: cast_nullable_to_non_nullable
                  as int,
        people: null == people
            ? _self.people
            : people // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
mixin _$NodeState {
  Side get controller;
  bool get evacuated;
  int get riceStock;

  /// Create a copy of NodeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NodeStateCopyWith<NodeState> get copyWith =>
      _$NodeStateCopyWithImpl<NodeState>(this as NodeState, _$identity);

  /// Serializes this NodeState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as NodeState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NodeState &&
            (identical(other.controller, _this.controller) ||
                other.controller == _this.controller) &&
            (identical(other.evacuated, _this.evacuated) ||
                other.evacuated == _this.evacuated) &&
            (identical(other.riceStock, _this.riceStock) ||
                other.riceStock == _this.riceStock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as NodeState;
    return Object.hash(
      runtimeType,
      _this.controller,
      _this.evacuated,
      _this.riceStock,
    );
  }

  @override
  String toString() {
    final _this = this as NodeState;
    return 'NodeState(controller: ${_this.controller}, evacuated: ${_this.evacuated}, riceStock: ${_this.riceStock})';
  }
}

/// @nodoc
abstract mixin class $NodeStateCopyWith<$Res> {
  factory $NodeStateCopyWith(NodeState value, $Res Function(NodeState) _then) =
      _$NodeStateCopyWithImpl;
  @useResult
  $Res call({Side controller, bool evacuated, int riceStock});
}

/// @nodoc
class _$NodeStateCopyWithImpl<$Res> implements $NodeStateCopyWith<$Res> {
  _$NodeStateCopyWithImpl(this._self, this._then);

  final NodeState _self;
  final $Res Function(NodeState) _then;

  /// Create a copy of NodeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = null,
    Object? evacuated = null,
    Object? riceStock = null,
  }) {
    return _then(
      NodeState(
        controller: null == controller
            ? _self.controller
            : controller // ignore: cast_nullable_to_non_nullable
                  as Side,
        evacuated: null == evacuated
            ? _self.evacuated
            : evacuated // ignore: cast_nullable_to_non_nullable
                  as bool,
        riceStock: null == riceStock
            ? _self.riceStock
            : riceStock // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [NodeState].
extension NodeStatePatterns on NodeState {
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
    TResult Function(_NodeState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NodeState() when $default != null:
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
    TResult Function(_NodeState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodeState():
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
    TResult? Function(_NodeState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodeState() when $default != null:
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
    TResult Function(Side controller, bool evacuated, int riceStock)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NodeState() when $default != null:
        return $default(_that.controller, _that.evacuated, _that.riceStock);
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
    TResult Function(Side controller, bool evacuated, int riceStock) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodeState():
        return $default(_that.controller, _that.evacuated, _that.riceStock);
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
    TResult? Function(Side controller, bool evacuated, int riceStock)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NodeState() when $default != null:
        return $default(_that.controller, _that.evacuated, _that.riceStock);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NodeState implements NodeState {
  const _NodeState({
    required this.controller,
    this.evacuated = false,
    required this.riceStock,
  });
  factory _NodeState.fromJson(Map<String, dynamic> json) =>
      _$NodeStateFromJson(json);

  @override
  final Side controller;
  @override
  @JsonKey()
  final bool evacuated;
  @override
  final int riceStock;

  /// Create a copy of NodeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NodeStateCopyWith<_NodeState> get copyWith =>
      __$NodeStateCopyWithImpl<_NodeState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NodeStateToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NodeState &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.evacuated, evacuated) ||
                other.evacuated == evacuated) &&
            (identical(other.riceStock, riceStock) ||
                other.riceStock == riceStock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, controller, evacuated, riceStock);
  }

  @override
  String toString() {
    return 'NodeState(controller: $controller, evacuated: $evacuated, riceStock: $riceStock)';
  }
}

/// @nodoc
abstract mixin class _$NodeStateCopyWith<$Res>
    implements $NodeStateCopyWith<$Res> {
  factory _$NodeStateCopyWith(
    _NodeState value,
    $Res Function(_NodeState) _then,
  ) = __$NodeStateCopyWithImpl;
  @override
  @useResult
  $Res call({Side controller, bool evacuated, int riceStock});
}

/// @nodoc
class __$NodeStateCopyWithImpl<$Res> implements _$NodeStateCopyWith<$Res> {
  __$NodeStateCopyWithImpl(this._self, this._then);

  final _NodeState _self;
  final $Res Function(_NodeState) _then;

  /// Create a copy of NodeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? controller = null,
    Object? evacuated = null,
    Object? riceStock = null,
  }) {
    return _then(
      _NodeState(
        controller: null == controller
            ? _self.controller
            : controller // ignore: cast_nullable_to_non_nullable
                  as Side,
        evacuated: null == evacuated
            ? _self.evacuated
            : evacuated // ignore: cast_nullable_to_non_nullable
                  as bool,
        riceStock: null == riceStock
            ? _self.riceStock
            : riceStock // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
mixin _$Order {
  OrderKind get kind;
  String? get target;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderCopyWith<Order> get copyWith =>
      _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as Order;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Order &&
            (identical(other.kind, _this.kind) || other.kind == _this.kind) &&
            (identical(other.target, _this.target) ||
                other.target == _this.target));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as Order;
    return Object.hash(runtimeType, _this.kind, _this.target);
  }

  @override
  String toString() {
    final _this = this as Order;
    return 'Order(kind: ${_this.kind}, target: ${_this.target})';
  }
}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) =
      _$OrderCopyWithImpl;
  @useResult
  $Res call({OrderKind kind, String? target});
}

/// @nodoc
class _$OrderCopyWithImpl<$Res> implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kind = null, Object? target = freezed}) {
    return _then(
      Order(
        kind: null == kind
            ? _self.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as OrderKind,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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
    TResult Function(_Order value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Order() when $default != null:
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
    TResult Function(_Order value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Order():
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
    TResult? Function(_Order value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Order() when $default != null:
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
    TResult Function(OrderKind kind, String? target)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Order() when $default != null:
        return $default(_that.kind, _that.target);
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
    TResult Function(OrderKind kind, String? target) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Order():
        return $default(_that.kind, _that.target);
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
    TResult? Function(OrderKind kind, String? target)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Order() when $default != null:
        return $default(_that.kind, _that.target);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Order implements Order {
  const _Order({required this.kind, this.target});
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  @override
  final OrderKind kind;
  @override
  final String? target;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderCopyWith<_Order> get copyWith =>
      __$OrderCopyWithImpl<_Order>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OrderToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Order &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.target, target) || other.target == target));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, kind, target);
  }

  @override
  String toString() {
    return 'Order(kind: $kind, target: $target)';
  }
}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) =
      __$OrderCopyWithImpl;
  @override
  @useResult
  $Res call({OrderKind kind, String? target});
}

/// @nodoc
class __$OrderCopyWithImpl<$Res> implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? kind = null, Object? target = freezed}) {
    return _then(
      _Order(
        kind: null == kind
            ? _self.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as OrderKind,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$OfficerState {
  String get nodeId;
  int get troops;
  int get morale;
  int get loyalty;
  OfficerStatus get status;
  Order? get order;
  int get skillUsesLeft;
  double get nextBattleMultiplier;

  /// Condition of [nextBattleMultiplier]: the opposing army must be below
  /// this fraction of its max Supply.
  double? get multiplierEnemySupplyBelow;

  /// Withdrawn by a card this turn: no battle and no orders until next turn.
  bool get withdrawn;

  /// Create a copy of OfficerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OfficerStateCopyWith<OfficerState> get copyWith =>
      _$OfficerStateCopyWithImpl<OfficerState>(
        this as OfficerState,
        _$identity,
      );

  /// Serializes this OfficerState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as OfficerState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OfficerState &&
            (identical(other.nodeId, _this.nodeId) ||
                other.nodeId == _this.nodeId) &&
            (identical(other.troops, _this.troops) ||
                other.troops == _this.troops) &&
            (identical(other.morale, _this.morale) ||
                other.morale == _this.morale) &&
            (identical(other.loyalty, _this.loyalty) ||
                other.loyalty == _this.loyalty) &&
            (identical(other.status, _this.status) ||
                other.status == _this.status) &&
            (identical(other.order, _this.order) ||
                other.order == _this.order) &&
            (identical(other.skillUsesLeft, _this.skillUsesLeft) ||
                other.skillUsesLeft == _this.skillUsesLeft) &&
            (identical(
                  other.nextBattleMultiplier,
                  _this.nextBattleMultiplier,
                ) ||
                other.nextBattleMultiplier == _this.nextBattleMultiplier) &&
            (identical(
                  other.multiplierEnemySupplyBelow,
                  _this.multiplierEnemySupplyBelow,
                ) ||
                other.multiplierEnemySupplyBelow ==
                    _this.multiplierEnemySupplyBelow) &&
            (identical(other.withdrawn, _this.withdrawn) ||
                other.withdrawn == _this.withdrawn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as OfficerState;
    return Object.hash(
      runtimeType,
      _this.nodeId,
      _this.troops,
      _this.morale,
      _this.loyalty,
      _this.status,
      _this.order,
      _this.skillUsesLeft,
      _this.nextBattleMultiplier,
      _this.multiplierEnemySupplyBelow,
      _this.withdrawn,
    );
  }

  @override
  String toString() {
    final _this = this as OfficerState;
    return 'OfficerState(nodeId: ${_this.nodeId}, troops: ${_this.troops}, morale: ${_this.morale}, loyalty: ${_this.loyalty}, status: ${_this.status}, order: ${_this.order}, skillUsesLeft: ${_this.skillUsesLeft}, nextBattleMultiplier: ${_this.nextBattleMultiplier}, multiplierEnemySupplyBelow: ${_this.multiplierEnemySupplyBelow}, withdrawn: ${_this.withdrawn})';
  }
}

/// @nodoc
abstract mixin class $OfficerStateCopyWith<$Res> {
  factory $OfficerStateCopyWith(
    OfficerState value,
    $Res Function(OfficerState) _then,
  ) = _$OfficerStateCopyWithImpl;
  @useResult
  $Res call({
    String nodeId,
    int troops,
    int morale,
    int loyalty,
    OfficerStatus status,
    Order? order,
    int skillUsesLeft,
    double nextBattleMultiplier,
    double? multiplierEnemySupplyBelow,
    bool withdrawn,
  });

  $OrderCopyWith<$Res>? get order;
}

/// @nodoc
class _$OfficerStateCopyWithImpl<$Res> implements $OfficerStateCopyWith<$Res> {
  _$OfficerStateCopyWithImpl(this._self, this._then);

  final OfficerState _self;
  final $Res Function(OfficerState) _then;

  /// Create a copy of OfficerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nodeId = null,
    Object? troops = null,
    Object? morale = null,
    Object? loyalty = null,
    Object? status = null,
    Object? order = freezed,
    Object? skillUsesLeft = null,
    Object? nextBattleMultiplier = null,
    Object? multiplierEnemySupplyBelow = freezed,
    Object? withdrawn = null,
  }) {
    return _then(
      OfficerState(
        nodeId: null == nodeId
            ? _self.nodeId
            : nodeId // ignore: cast_nullable_to_non_nullable
                  as String,
        troops: null == troops
            ? _self.troops
            : troops // ignore: cast_nullable_to_non_nullable
                  as int,
        morale: null == morale
            ? _self.morale
            : morale // ignore: cast_nullable_to_non_nullable
                  as int,
        loyalty: null == loyalty
            ? _self.loyalty
            : loyalty // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OfficerStatus,
        order: freezed == order
            ? _self.order
            : order // ignore: cast_nullable_to_non_nullable
                  as Order?,
        skillUsesLeft: null == skillUsesLeft
            ? _self.skillUsesLeft
            : skillUsesLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        nextBattleMultiplier: null == nextBattleMultiplier
            ? _self.nextBattleMultiplier
            : nextBattleMultiplier // ignore: cast_nullable_to_non_nullable
                  as double,
        multiplierEnemySupplyBelow: freezed == multiplierEnemySupplyBelow
            ? _self.multiplierEnemySupplyBelow
            : multiplierEnemySupplyBelow // ignore: cast_nullable_to_non_nullable
                  as double?,
        withdrawn: null == withdrawn
            ? _self.withdrawn
            : withdrawn // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }

  /// Create a copy of OfficerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res>? get order {
    if (_self.order == null) {
      return null;
    }

    return $OrderCopyWith<$Res>(_self.order!, (value) {
      return _then(_self.copyWith(order: value));
    });
  }
}

/// Adds pattern-matching-related methods to [OfficerState].
extension OfficerStatePatterns on OfficerState {
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
    TResult Function(_OfficerState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OfficerState() when $default != null:
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
    TResult Function(_OfficerState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OfficerState():
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
    TResult? Function(_OfficerState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OfficerState() when $default != null:
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
      String nodeId,
      int troops,
      int morale,
      int loyalty,
      OfficerStatus status,
      Order? order,
      int skillUsesLeft,
      double nextBattleMultiplier,
      double? multiplierEnemySupplyBelow,
      bool withdrawn,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OfficerState() when $default != null:
        return $default(
          _that.nodeId,
          _that.troops,
          _that.morale,
          _that.loyalty,
          _that.status,
          _that.order,
          _that.skillUsesLeft,
          _that.nextBattleMultiplier,
          _that.multiplierEnemySupplyBelow,
          _that.withdrawn,
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
      String nodeId,
      int troops,
      int morale,
      int loyalty,
      OfficerStatus status,
      Order? order,
      int skillUsesLeft,
      double nextBattleMultiplier,
      double? multiplierEnemySupplyBelow,
      bool withdrawn,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OfficerState():
        return $default(
          _that.nodeId,
          _that.troops,
          _that.morale,
          _that.loyalty,
          _that.status,
          _that.order,
          _that.skillUsesLeft,
          _that.nextBattleMultiplier,
          _that.multiplierEnemySupplyBelow,
          _that.withdrawn,
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
      String nodeId,
      int troops,
      int morale,
      int loyalty,
      OfficerStatus status,
      Order? order,
      int skillUsesLeft,
      double nextBattleMultiplier,
      double? multiplierEnemySupplyBelow,
      bool withdrawn,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OfficerState() when $default != null:
        return $default(
          _that.nodeId,
          _that.troops,
          _that.morale,
          _that.loyalty,
          _that.status,
          _that.order,
          _that.skillUsesLeft,
          _that.nextBattleMultiplier,
          _that.multiplierEnemySupplyBelow,
          _that.withdrawn,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OfficerState implements OfficerState {
  const _OfficerState({
    required this.nodeId,
    required this.troops,
    required this.morale,
    required this.loyalty,
    this.status = OfficerStatus.active,
    this.order,
    this.skillUsesLeft = 0,
    this.nextBattleMultiplier = 1.0,
    this.multiplierEnemySupplyBelow,
    this.withdrawn = false,
  });
  factory _OfficerState.fromJson(Map<String, dynamic> json) =>
      _$OfficerStateFromJson(json);

  @override
  final String nodeId;
  @override
  final int troops;
  @override
  final int morale;
  @override
  final int loyalty;
  @override
  @JsonKey()
  final OfficerStatus status;
  @override
  final Order? order;
  @override
  @JsonKey()
  final int skillUsesLeft;
  @override
  @JsonKey()
  final double nextBattleMultiplier;

  /// Condition of [nextBattleMultiplier]: the opposing army must be below
  /// this fraction of its max Supply.
  @override
  final double? multiplierEnemySupplyBelow;

  /// Withdrawn by a card this turn: no battle and no orders until next turn.
  @override
  @JsonKey()
  final bool withdrawn;

  /// Create a copy of OfficerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OfficerStateCopyWith<_OfficerState> get copyWith =>
      __$OfficerStateCopyWithImpl<_OfficerState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OfficerStateToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OfficerState &&
            (identical(other.nodeId, nodeId) || other.nodeId == nodeId) &&
            (identical(other.troops, troops) || other.troops == troops) &&
            (identical(other.morale, morale) || other.morale == morale) &&
            (identical(other.loyalty, loyalty) || other.loyalty == loyalty) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.skillUsesLeft, skillUsesLeft) ||
                other.skillUsesLeft == skillUsesLeft) &&
            (identical(other.nextBattleMultiplier, nextBattleMultiplier) ||
                other.nextBattleMultiplier == nextBattleMultiplier) &&
            (identical(
                  other.multiplierEnemySupplyBelow,
                  multiplierEnemySupplyBelow,
                ) ||
                other.multiplierEnemySupplyBelow ==
                    multiplierEnemySupplyBelow) &&
            (identical(other.withdrawn, withdrawn) ||
                other.withdrawn == withdrawn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      nodeId,
      troops,
      morale,
      loyalty,
      status,
      order,
      skillUsesLeft,
      nextBattleMultiplier,
      multiplierEnemySupplyBelow,
      withdrawn,
    );
  }

  @override
  String toString() {
    return 'OfficerState(nodeId: $nodeId, troops: $troops, morale: $morale, loyalty: $loyalty, status: $status, order: $order, skillUsesLeft: $skillUsesLeft, nextBattleMultiplier: $nextBattleMultiplier, multiplierEnemySupplyBelow: $multiplierEnemySupplyBelow, withdrawn: $withdrawn)';
  }
}

/// @nodoc
abstract mixin class _$OfficerStateCopyWith<$Res>
    implements $OfficerStateCopyWith<$Res> {
  factory _$OfficerStateCopyWith(
    _OfficerState value,
    $Res Function(_OfficerState) _then,
  ) = __$OfficerStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    String nodeId,
    int troops,
    int morale,
    int loyalty,
    OfficerStatus status,
    Order? order,
    int skillUsesLeft,
    double nextBattleMultiplier,
    double? multiplierEnemySupplyBelow,
    bool withdrawn,
  });

  @override
  $OrderCopyWith<$Res>? get order;
}

/// @nodoc
class __$OfficerStateCopyWithImpl<$Res>
    implements _$OfficerStateCopyWith<$Res> {
  __$OfficerStateCopyWithImpl(this._self, this._then);

  final _OfficerState _self;
  final $Res Function(_OfficerState) _then;

  /// Create a copy of OfficerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? nodeId = null,
    Object? troops = null,
    Object? morale = null,
    Object? loyalty = null,
    Object? status = null,
    Object? order = freezed,
    Object? skillUsesLeft = null,
    Object? nextBattleMultiplier = null,
    Object? multiplierEnemySupplyBelow = freezed,
    Object? withdrawn = null,
  }) {
    return _then(
      _OfficerState(
        nodeId: null == nodeId
            ? _self.nodeId
            : nodeId // ignore: cast_nullable_to_non_nullable
                  as String,
        troops: null == troops
            ? _self.troops
            : troops // ignore: cast_nullable_to_non_nullable
                  as int,
        morale: null == morale
            ? _self.morale
            : morale // ignore: cast_nullable_to_non_nullable
                  as int,
        loyalty: null == loyalty
            ? _self.loyalty
            : loyalty // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OfficerStatus,
        order: freezed == order
            ? _self.order
            : order // ignore: cast_nullable_to_non_nullable
                  as Order?,
        skillUsesLeft: null == skillUsesLeft
            ? _self.skillUsesLeft
            : skillUsesLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        nextBattleMultiplier: null == nextBattleMultiplier
            ? _self.nextBattleMultiplier
            : nextBattleMultiplier // ignore: cast_nullable_to_non_nullable
                  as double,
        multiplierEnemySupplyBelow: freezed == multiplierEnemySupplyBelow
            ? _self.multiplierEnemySupplyBelow
            : multiplierEnemySupplyBelow // ignore: cast_nullable_to_non_nullable
                  as double?,
        withdrawn: null == withdrawn
            ? _self.withdrawn
            : withdrawn // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }

  /// Create a copy of OfficerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res>? get order {
    if (_self.order == null) {
      return null;
    }

    return $OrderCopyWith<$Res>(_self.order!, (value) {
      return _then(_self.copyWith(order: value));
    });
  }
}

/// @nodoc
mixin _$Intent {
  IntentKind get kind;
  String? get moveTo;
  String? get targetNodeId;

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IntentCopyWith<Intent> get copyWith =>
      _$IntentCopyWithImpl<Intent>(this as Intent, _$identity);

  /// Serializes this Intent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as Intent;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Intent &&
            (identical(other.kind, _this.kind) || other.kind == _this.kind) &&
            (identical(other.moveTo, _this.moveTo) ||
                other.moveTo == _this.moveTo) &&
            (identical(other.targetNodeId, _this.targetNodeId) ||
                other.targetNodeId == _this.targetNodeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as Intent;
    return Object.hash(
      runtimeType,
      _this.kind,
      _this.moveTo,
      _this.targetNodeId,
    );
  }

  @override
  String toString() {
    final _this = this as Intent;
    return 'Intent(kind: ${_this.kind}, moveTo: ${_this.moveTo}, targetNodeId: ${_this.targetNodeId})';
  }
}

/// @nodoc
abstract mixin class $IntentCopyWith<$Res> {
  factory $IntentCopyWith(Intent value, $Res Function(Intent) _then) =
      _$IntentCopyWithImpl;
  @useResult
  $Res call({IntentKind kind, String? moveTo, String? targetNodeId});
}

/// @nodoc
class _$IntentCopyWithImpl<$Res> implements $IntentCopyWith<$Res> {
  _$IntentCopyWithImpl(this._self, this._then);

  final Intent _self;
  final $Res Function(Intent) _then;

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? moveTo = freezed,
    Object? targetNodeId = freezed,
  }) {
    return _then(
      Intent(
        kind: null == kind
            ? _self.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as IntentKind,
        moveTo: freezed == moveTo
            ? _self.moveTo
            : moveTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetNodeId: freezed == targetNodeId
            ? _self.targetNodeId
            : targetNodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Intent].
extension IntentPatterns on Intent {
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
    TResult Function(_Intent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Intent() when $default != null:
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
    TResult Function(_Intent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Intent():
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
    TResult? Function(_Intent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Intent() when $default != null:
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
    TResult Function(IntentKind kind, String? moveTo, String? targetNodeId)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Intent() when $default != null:
        return $default(_that.kind, _that.moveTo, _that.targetNodeId);
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
    TResult Function(IntentKind kind, String? moveTo, String? targetNodeId)
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Intent():
        return $default(_that.kind, _that.moveTo, _that.targetNodeId);
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
    TResult? Function(IntentKind kind, String? moveTo, String? targetNodeId)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Intent() when $default != null:
        return $default(_that.kind, _that.moveTo, _that.targetNodeId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Intent implements Intent {
  const _Intent({required this.kind, this.moveTo, this.targetNodeId});
  factory _Intent.fromJson(Map<String, dynamic> json) => _$IntentFromJson(json);

  @override
  final IntentKind kind;
  @override
  final String? moveTo;
  @override
  final String? targetNodeId;

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IntentCopyWith<_Intent> get copyWith =>
      __$IntentCopyWithImpl<_Intent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IntentToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Intent &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.moveTo, moveTo) || other.moveTo == moveTo) &&
            (identical(other.targetNodeId, targetNodeId) ||
                other.targetNodeId == targetNodeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, kind, moveTo, targetNodeId);
  }

  @override
  String toString() {
    return 'Intent(kind: $kind, moveTo: $moveTo, targetNodeId: $targetNodeId)';
  }
}

/// @nodoc
abstract mixin class _$IntentCopyWith<$Res> implements $IntentCopyWith<$Res> {
  factory _$IntentCopyWith(_Intent value, $Res Function(_Intent) _then) =
      __$IntentCopyWithImpl;
  @override
  @useResult
  $Res call({IntentKind kind, String? moveTo, String? targetNodeId});
}

/// @nodoc
class __$IntentCopyWithImpl<$Res> implements _$IntentCopyWith<$Res> {
  __$IntentCopyWithImpl(this._self, this._then);

  final _Intent _self;
  final $Res Function(_Intent) _then;

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? kind = null,
    Object? moveTo = freezed,
    Object? targetNodeId = freezed,
  }) {
    return _then(
      _Intent(
        kind: null == kind
            ? _self.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as IntentKind,
        moveTo: freezed == moveTo
            ? _self.moveTo
            : moveTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetNodeId: freezed == targetNodeId
            ? _self.targetNodeId
            : targetNodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$ArmyState {
  String get commanderId;
  String get nodeId;
  int get troops;
  int get supply;
  int get maxSupply;
  int get morale;
  String get retreatNodeId;
  Intent? get intent;

  /// Next turn's intent, shown as "predicted" when `revealDepth` ≥ 2.
  Intent? get predictedIntent;
  ArmyStatus get status;

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ArmyStateCopyWith<ArmyState> get copyWith =>
      _$ArmyStateCopyWithImpl<ArmyState>(this as ArmyState, _$identity);

  /// Serializes this ArmyState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as ArmyState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ArmyState &&
            (identical(other.commanderId, _this.commanderId) ||
                other.commanderId == _this.commanderId) &&
            (identical(other.nodeId, _this.nodeId) ||
                other.nodeId == _this.nodeId) &&
            (identical(other.troops, _this.troops) ||
                other.troops == _this.troops) &&
            (identical(other.supply, _this.supply) ||
                other.supply == _this.supply) &&
            (identical(other.maxSupply, _this.maxSupply) ||
                other.maxSupply == _this.maxSupply) &&
            (identical(other.morale, _this.morale) ||
                other.morale == _this.morale) &&
            (identical(other.retreatNodeId, _this.retreatNodeId) ||
                other.retreatNodeId == _this.retreatNodeId) &&
            (identical(other.intent, _this.intent) ||
                other.intent == _this.intent) &&
            (identical(other.predictedIntent, _this.predictedIntent) ||
                other.predictedIntent == _this.predictedIntent) &&
            (identical(other.status, _this.status) ||
                other.status == _this.status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as ArmyState;
    return Object.hash(
      runtimeType,
      _this.commanderId,
      _this.nodeId,
      _this.troops,
      _this.supply,
      _this.maxSupply,
      _this.morale,
      _this.retreatNodeId,
      _this.intent,
      _this.predictedIntent,
      _this.status,
    );
  }

  @override
  String toString() {
    final _this = this as ArmyState;
    return 'ArmyState(commanderId: ${_this.commanderId}, nodeId: ${_this.nodeId}, troops: ${_this.troops}, supply: ${_this.supply}, maxSupply: ${_this.maxSupply}, morale: ${_this.morale}, retreatNodeId: ${_this.retreatNodeId}, intent: ${_this.intent}, predictedIntent: ${_this.predictedIntent}, status: ${_this.status})';
  }
}

/// @nodoc
abstract mixin class $ArmyStateCopyWith<$Res> {
  factory $ArmyStateCopyWith(ArmyState value, $Res Function(ArmyState) _then) =
      _$ArmyStateCopyWithImpl;
  @useResult
  $Res call({
    String commanderId,
    String nodeId,
    int troops,
    int supply,
    int maxSupply,
    int morale,
    String retreatNodeId,
    Intent? intent,
    Intent? predictedIntent,
    ArmyStatus status,
  });

  $IntentCopyWith<$Res>? get intent;
  $IntentCopyWith<$Res>? get predictedIntent;
}

/// @nodoc
class _$ArmyStateCopyWithImpl<$Res> implements $ArmyStateCopyWith<$Res> {
  _$ArmyStateCopyWithImpl(this._self, this._then);

  final ArmyState _self;
  final $Res Function(ArmyState) _then;

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commanderId = null,
    Object? nodeId = null,
    Object? troops = null,
    Object? supply = null,
    Object? maxSupply = null,
    Object? morale = null,
    Object? retreatNodeId = null,
    Object? intent = freezed,
    Object? predictedIntent = freezed,
    Object? status = null,
  }) {
    return _then(
      ArmyState(
        commanderId: null == commanderId
            ? _self.commanderId
            : commanderId // ignore: cast_nullable_to_non_nullable
                  as String,
        nodeId: null == nodeId
            ? _self.nodeId
            : nodeId // ignore: cast_nullable_to_non_nullable
                  as String,
        troops: null == troops
            ? _self.troops
            : troops // ignore: cast_nullable_to_non_nullable
                  as int,
        supply: null == supply
            ? _self.supply
            : supply // ignore: cast_nullable_to_non_nullable
                  as int,
        maxSupply: null == maxSupply
            ? _self.maxSupply
            : maxSupply // ignore: cast_nullable_to_non_nullable
                  as int,
        morale: null == morale
            ? _self.morale
            : morale // ignore: cast_nullable_to_non_nullable
                  as int,
        retreatNodeId: null == retreatNodeId
            ? _self.retreatNodeId
            : retreatNodeId // ignore: cast_nullable_to_non_nullable
                  as String,
        intent: freezed == intent
            ? _self.intent
            : intent // ignore: cast_nullable_to_non_nullable
                  as Intent?,
        predictedIntent: freezed == predictedIntent
            ? _self.predictedIntent
            : predictedIntent // ignore: cast_nullable_to_non_nullable
                  as Intent?,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ArmyStatus,
      ),
    );
  }

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IntentCopyWith<$Res>? get intent {
    if (_self.intent == null) {
      return null;
    }

    return $IntentCopyWith<$Res>(_self.intent!, (value) {
      return _then(_self.copyWith(intent: value));
    });
  }

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IntentCopyWith<$Res>? get predictedIntent {
    if (_self.predictedIntent == null) {
      return null;
    }

    return $IntentCopyWith<$Res>(_self.predictedIntent!, (value) {
      return _then(_self.copyWith(predictedIntent: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ArmyState].
extension ArmyStatePatterns on ArmyState {
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
    TResult Function(_ArmyState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ArmyState() when $default != null:
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
    TResult Function(_ArmyState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArmyState():
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
    TResult? Function(_ArmyState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArmyState() when $default != null:
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
      String commanderId,
      String nodeId,
      int troops,
      int supply,
      int maxSupply,
      int morale,
      String retreatNodeId,
      Intent? intent,
      Intent? predictedIntent,
      ArmyStatus status,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ArmyState() when $default != null:
        return $default(
          _that.commanderId,
          _that.nodeId,
          _that.troops,
          _that.supply,
          _that.maxSupply,
          _that.morale,
          _that.retreatNodeId,
          _that.intent,
          _that.predictedIntent,
          _that.status,
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
      String commanderId,
      String nodeId,
      int troops,
      int supply,
      int maxSupply,
      int morale,
      String retreatNodeId,
      Intent? intent,
      Intent? predictedIntent,
      ArmyStatus status,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArmyState():
        return $default(
          _that.commanderId,
          _that.nodeId,
          _that.troops,
          _that.supply,
          _that.maxSupply,
          _that.morale,
          _that.retreatNodeId,
          _that.intent,
          _that.predictedIntent,
          _that.status,
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
      String commanderId,
      String nodeId,
      int troops,
      int supply,
      int maxSupply,
      int morale,
      String retreatNodeId,
      Intent? intent,
      Intent? predictedIntent,
      ArmyStatus status,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ArmyState() when $default != null:
        return $default(
          _that.commanderId,
          _that.nodeId,
          _that.troops,
          _that.supply,
          _that.maxSupply,
          _that.morale,
          _that.retreatNodeId,
          _that.intent,
          _that.predictedIntent,
          _that.status,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ArmyState implements ArmyState {
  const _ArmyState({
    required this.commanderId,
    required this.nodeId,
    required this.troops,
    required this.supply,
    required this.maxSupply,
    required this.morale,
    required this.retreatNodeId,
    this.intent,
    this.predictedIntent,
    this.status = ArmyStatus.active,
  });
  factory _ArmyState.fromJson(Map<String, dynamic> json) =>
      _$ArmyStateFromJson(json);

  @override
  final String commanderId;
  @override
  final String nodeId;
  @override
  final int troops;
  @override
  final int supply;
  @override
  final int maxSupply;
  @override
  final int morale;
  @override
  final String retreatNodeId;
  @override
  final Intent? intent;

  /// Next turn's intent, shown as "predicted" when `revealDepth` ≥ 2.
  @override
  final Intent? predictedIntent;
  @override
  @JsonKey()
  final ArmyStatus status;

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ArmyStateCopyWith<_ArmyState> get copyWith =>
      __$ArmyStateCopyWithImpl<_ArmyState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ArmyStateToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ArmyState &&
            (identical(other.commanderId, commanderId) ||
                other.commanderId == commanderId) &&
            (identical(other.nodeId, nodeId) || other.nodeId == nodeId) &&
            (identical(other.troops, troops) || other.troops == troops) &&
            (identical(other.supply, supply) || other.supply == supply) &&
            (identical(other.maxSupply, maxSupply) ||
                other.maxSupply == maxSupply) &&
            (identical(other.morale, morale) || other.morale == morale) &&
            (identical(other.retreatNodeId, retreatNodeId) ||
                other.retreatNodeId == retreatNodeId) &&
            (identical(other.intent, intent) || other.intent == intent) &&
            (identical(other.predictedIntent, predictedIntent) ||
                other.predictedIntent == predictedIntent) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      commanderId,
      nodeId,
      troops,
      supply,
      maxSupply,
      morale,
      retreatNodeId,
      intent,
      predictedIntent,
      status,
    );
  }

  @override
  String toString() {
    return 'ArmyState(commanderId: $commanderId, nodeId: $nodeId, troops: $troops, supply: $supply, maxSupply: $maxSupply, morale: $morale, retreatNodeId: $retreatNodeId, intent: $intent, predictedIntent: $predictedIntent, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$ArmyStateCopyWith<$Res>
    implements $ArmyStateCopyWith<$Res> {
  factory _$ArmyStateCopyWith(
    _ArmyState value,
    $Res Function(_ArmyState) _then,
  ) = __$ArmyStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    String commanderId,
    String nodeId,
    int troops,
    int supply,
    int maxSupply,
    int morale,
    String retreatNodeId,
    Intent? intent,
    Intent? predictedIntent,
    ArmyStatus status,
  });

  @override
  $IntentCopyWith<$Res>? get intent;
  @override
  $IntentCopyWith<$Res>? get predictedIntent;
}

/// @nodoc
class __$ArmyStateCopyWithImpl<$Res> implements _$ArmyStateCopyWith<$Res> {
  __$ArmyStateCopyWithImpl(this._self, this._then);

  final _ArmyState _self;
  final $Res Function(_ArmyState) _then;

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commanderId = null,
    Object? nodeId = null,
    Object? troops = null,
    Object? supply = null,
    Object? maxSupply = null,
    Object? morale = null,
    Object? retreatNodeId = null,
    Object? intent = freezed,
    Object? predictedIntent = freezed,
    Object? status = null,
  }) {
    return _then(
      _ArmyState(
        commanderId: null == commanderId
            ? _self.commanderId
            : commanderId // ignore: cast_nullable_to_non_nullable
                  as String,
        nodeId: null == nodeId
            ? _self.nodeId
            : nodeId // ignore: cast_nullable_to_non_nullable
                  as String,
        troops: null == troops
            ? _self.troops
            : troops // ignore: cast_nullable_to_non_nullable
                  as int,
        supply: null == supply
            ? _self.supply
            : supply // ignore: cast_nullable_to_non_nullable
                  as int,
        maxSupply: null == maxSupply
            ? _self.maxSupply
            : maxSupply // ignore: cast_nullable_to_non_nullable
                  as int,
        morale: null == morale
            ? _self.morale
            : morale // ignore: cast_nullable_to_non_nullable
                  as int,
        retreatNodeId: null == retreatNodeId
            ? _self.retreatNodeId
            : retreatNodeId // ignore: cast_nullable_to_non_nullable
                  as String,
        intent: freezed == intent
            ? _self.intent
            : intent // ignore: cast_nullable_to_non_nullable
                  as Intent?,
        predictedIntent: freezed == predictedIntent
            ? _self.predictedIntent
            : predictedIntent // ignore: cast_nullable_to_non_nullable
                  as Intent?,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ArmyStatus,
      ),
    );
  }

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IntentCopyWith<$Res>? get intent {
    if (_self.intent == null) {
      return null;
    }

    return $IntentCopyWith<$Res>(_self.intent!, (value) {
      return _then(_self.copyWith(intent: value));
    });
  }

  /// Create a copy of ArmyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IntentCopyWith<$Res>? get predictedIntent {
    if (_self.predictedIntent == null) {
      return null;
    }

    return $IntentCopyWith<$Res>(_self.predictedIntent!, (value) {
      return _then(_self.copyWith(predictedIntent: value));
    });
  }
}

/// @nodoc
mixin _$Ambush {
  String get edge;
  String get officerId;

  /// Create a copy of Ambush
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AmbushCopyWith<Ambush> get copyWith =>
      _$AmbushCopyWithImpl<Ambush>(this as Ambush, _$identity);

  /// Serializes this Ambush to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as Ambush;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Ambush &&
            (identical(other.edge, _this.edge) || other.edge == _this.edge) &&
            (identical(other.officerId, _this.officerId) ||
                other.officerId == _this.officerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as Ambush;
    return Object.hash(runtimeType, _this.edge, _this.officerId);
  }

  @override
  String toString() {
    final _this = this as Ambush;
    return 'Ambush(edge: ${_this.edge}, officerId: ${_this.officerId})';
  }
}

/// @nodoc
abstract mixin class $AmbushCopyWith<$Res> {
  factory $AmbushCopyWith(Ambush value, $Res Function(Ambush) _then) =
      _$AmbushCopyWithImpl;
  @useResult
  $Res call({String edge, String officerId});
}

/// @nodoc
class _$AmbushCopyWithImpl<$Res> implements $AmbushCopyWith<$Res> {
  _$AmbushCopyWithImpl(this._self, this._then);

  final Ambush _self;
  final $Res Function(Ambush) _then;

  /// Create a copy of Ambush
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? edge = null, Object? officerId = null}) {
    return _then(
      Ambush(
        edge: null == edge
            ? _self.edge
            : edge // ignore: cast_nullable_to_non_nullable
                  as String,
        officerId: null == officerId
            ? _self.officerId
            : officerId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Ambush].
extension AmbushPatterns on Ambush {
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
    TResult Function(_Ambush value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Ambush() when $default != null:
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
    TResult Function(_Ambush value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ambush():
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
    TResult? Function(_Ambush value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ambush() when $default != null:
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
    TResult Function(String edge, String officerId)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Ambush() when $default != null:
        return $default(_that.edge, _that.officerId);
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
    TResult Function(String edge, String officerId) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ambush():
        return $default(_that.edge, _that.officerId);
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
    TResult? Function(String edge, String officerId)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ambush() when $default != null:
        return $default(_that.edge, _that.officerId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Ambush implements Ambush {
  const _Ambush({required this.edge, required this.officerId});
  factory _Ambush.fromJson(Map<String, dynamic> json) => _$AmbushFromJson(json);

  @override
  final String edge;
  @override
  final String officerId;

  /// Create a copy of Ambush
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AmbushCopyWith<_Ambush> get copyWith =>
      __$AmbushCopyWithImpl<_Ambush>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AmbushToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Ambush &&
            (identical(other.edge, edge) || other.edge == edge) &&
            (identical(other.officerId, officerId) ||
                other.officerId == officerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, edge, officerId);
  }

  @override
  String toString() {
    return 'Ambush(edge: $edge, officerId: $officerId)';
  }
}

/// @nodoc
abstract mixin class _$AmbushCopyWith<$Res> implements $AmbushCopyWith<$Res> {
  factory _$AmbushCopyWith(_Ambush value, $Res Function(_Ambush) _then) =
      __$AmbushCopyWithImpl;
  @override
  @useResult
  $Res call({String edge, String officerId});
}

/// @nodoc
class __$AmbushCopyWithImpl<$Res> implements _$AmbushCopyWith<$Res> {
  __$AmbushCopyWithImpl(this._self, this._then);

  final _Ambush _self;
  final $Res Function(_Ambush) _then;

  /// Create a copy of Ambush
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? edge = null, Object? officerId = null}) {
    return _then(
      _Ambush(
        edge: null == edge
            ? _self.edge
            : edge // ignore: cast_nullable_to_non_nullable
                  as String,
        officerId: null == officerId
            ? _self.officerId
            : officerId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
mixin _$PendingChoice {
  ChoiceSource get source;
  String get sourceId;
  List<int> get path;
  int get optionCount;
  Map<String, String> get bindings;

  /// Create a copy of PendingChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PendingChoiceCopyWith<PendingChoice> get copyWith =>
      _$PendingChoiceCopyWithImpl<PendingChoice>(
        this as PendingChoice,
        _$identity,
      );

  /// Serializes this PendingChoice to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as PendingChoice;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PendingChoice &&
            (identical(other.source, _this.source) ||
                other.source == _this.source) &&
            (identical(other.sourceId, _this.sourceId) ||
                other.sourceId == _this.sourceId) &&
            const DeepCollectionEquality().equals(other.path, _this.path) &&
            (identical(other.optionCount, _this.optionCount) ||
                other.optionCount == _this.optionCount) &&
            const DeepCollectionEquality().equals(
              other.bindings,
              _this.bindings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as PendingChoice;
    return Object.hash(
      runtimeType,
      _this.source,
      _this.sourceId,
      const DeepCollectionEquality().hash(_this.path),
      _this.optionCount,
      const DeepCollectionEquality().hash(_this.bindings),
    );
  }

  @override
  String toString() {
    final _this = this as PendingChoice;
    return 'PendingChoice(source: ${_this.source}, sourceId: ${_this.sourceId}, path: ${_this.path}, optionCount: ${_this.optionCount}, bindings: ${_this.bindings})';
  }
}

/// @nodoc
abstract mixin class $PendingChoiceCopyWith<$Res> {
  factory $PendingChoiceCopyWith(
    PendingChoice value,
    $Res Function(PendingChoice) _then,
  ) = _$PendingChoiceCopyWithImpl;
  @useResult
  $Res call({
    ChoiceSource source,
    String sourceId,
    List<int> path,
    int optionCount,
    Map<String, String> bindings,
  });
}

/// @nodoc
class _$PendingChoiceCopyWithImpl<$Res>
    implements $PendingChoiceCopyWith<$Res> {
  _$PendingChoiceCopyWithImpl(this._self, this._then);

  final PendingChoice _self;
  final $Res Function(PendingChoice) _then;

  /// Create a copy of PendingChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? sourceId = null,
    Object? path = null,
    Object? optionCount = null,
    Object? bindings = null,
  }) {
    return _then(
      PendingChoice(
        source: null == source
            ? _self.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ChoiceSource,
        sourceId: null == sourceId
            ? _self.sourceId
            : sourceId // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        optionCount: null == optionCount
            ? _self.optionCount
            : optionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        bindings: null == bindings
            ? _self.bindings
            : bindings // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [PendingChoice].
extension PendingChoicePatterns on PendingChoice {
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
    TResult Function(_PendingChoice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PendingChoice() when $default != null:
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
    TResult Function(_PendingChoice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingChoice():
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
    TResult? Function(_PendingChoice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingChoice() when $default != null:
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
      ChoiceSource source,
      String sourceId,
      List<int> path,
      int optionCount,
      Map<String, String> bindings,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PendingChoice() when $default != null:
        return $default(
          _that.source,
          _that.sourceId,
          _that.path,
          _that.optionCount,
          _that.bindings,
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
      ChoiceSource source,
      String sourceId,
      List<int> path,
      int optionCount,
      Map<String, String> bindings,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingChoice():
        return $default(
          _that.source,
          _that.sourceId,
          _that.path,
          _that.optionCount,
          _that.bindings,
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
      ChoiceSource source,
      String sourceId,
      List<int> path,
      int optionCount,
      Map<String, String> bindings,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingChoice() when $default != null:
        return $default(
          _that.source,
          _that.sourceId,
          _that.path,
          _that.optionCount,
          _that.bindings,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PendingChoice implements PendingChoice {
  const _PendingChoice({
    required this.source,
    required this.sourceId,
    required List<int> path,
    required this.optionCount,
    Map<String, String> bindings = const <String, String>{},
  }) : _path = path,
       _bindings = bindings;
  factory _PendingChoice.fromJson(Map<String, dynamic> json) =>
      _$PendingChoiceFromJson(json);

  @override
  final ChoiceSource source;
  @override
  final String sourceId;
  final List<int> _path;
  @override
  List<int> get path {
    if (_path is EqualUnmodifiableListView) return _path;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_path);
  }

  @override
  final int optionCount;
  final Map<String, String> _bindings;
  @override
  @JsonKey()
  Map<String, String> get bindings {
    if (_bindings is EqualUnmodifiableMapView) return _bindings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bindings);
  }

  /// Create a copy of PendingChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PendingChoiceCopyWith<_PendingChoice> get copyWith =>
      __$PendingChoiceCopyWithImpl<_PendingChoice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PendingChoiceToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PendingChoice &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            const DeepCollectionEquality().equals(other.path, _path) &&
            (identical(other.optionCount, optionCount) ||
                other.optionCount == optionCount) &&
            const DeepCollectionEquality().equals(other.bindings, _bindings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      source,
      sourceId,
      const DeepCollectionEquality().hash(_path),
      optionCount,
      const DeepCollectionEquality().hash(_bindings),
    );
  }

  @override
  String toString() {
    return 'PendingChoice(source: $source, sourceId: $sourceId, path: $path, optionCount: $optionCount, bindings: $bindings)';
  }
}

/// @nodoc
abstract mixin class _$PendingChoiceCopyWith<$Res>
    implements $PendingChoiceCopyWith<$Res> {
  factory _$PendingChoiceCopyWith(
    _PendingChoice value,
    $Res Function(_PendingChoice) _then,
  ) = __$PendingChoiceCopyWithImpl;
  @override
  @useResult
  $Res call({
    ChoiceSource source,
    String sourceId,
    List<int> path,
    int optionCount,
    Map<String, String> bindings,
  });
}

/// @nodoc
class __$PendingChoiceCopyWithImpl<$Res>
    implements _$PendingChoiceCopyWith<$Res> {
  __$PendingChoiceCopyWithImpl(this._self, this._then);

  final _PendingChoice _self;
  final $Res Function(_PendingChoice) _then;

  /// Create a copy of PendingChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? source = null,
    Object? sourceId = null,
    Object? path = null,
    Object? optionCount = null,
    Object? bindings = null,
  }) {
    return _then(
      _PendingChoice(
        source: null == source
            ? _self.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ChoiceSource,
        sourceId: null == sourceId
            ? _self.sourceId
            : sourceId // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self._path
            : path // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        optionCount: null == optionCount
            ? _self.optionCount
            : optionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        bindings: null == bindings
            ? _self._bindings
            : bindings // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc
mixin _$MissionStats {
  int get troopsLost;
  int get defections;
  int get captures;
  int get battlesWon;
  int get battlesLost;
  int get evacuations;
  int get raids;
  int get ambushesTriggered;
  Map<String, int> get cardsPlayed;
  Map<String, int> get skillsUsed;

  /// Nodes where a `counterattackAt` battle was won.
  List<String> get counterattackNodes;
  int? get wonOnTurn;

  /// Create a copy of MissionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MissionStatsCopyWith<MissionStats> get copyWith =>
      _$MissionStatsCopyWithImpl<MissionStats>(
        this as MissionStats,
        _$identity,
      );

  /// Serializes this MissionStats to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as MissionStats;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MissionStats &&
            (identical(other.troopsLost, _this.troopsLost) ||
                other.troopsLost == _this.troopsLost) &&
            (identical(other.defections, _this.defections) ||
                other.defections == _this.defections) &&
            (identical(other.captures, _this.captures) ||
                other.captures == _this.captures) &&
            (identical(other.battlesWon, _this.battlesWon) ||
                other.battlesWon == _this.battlesWon) &&
            (identical(other.battlesLost, _this.battlesLost) ||
                other.battlesLost == _this.battlesLost) &&
            (identical(other.evacuations, _this.evacuations) ||
                other.evacuations == _this.evacuations) &&
            (identical(other.raids, _this.raids) ||
                other.raids == _this.raids) &&
            (identical(other.ambushesTriggered, _this.ambushesTriggered) ||
                other.ambushesTriggered == _this.ambushesTriggered) &&
            const DeepCollectionEquality().equals(
              other.cardsPlayed,
              _this.cardsPlayed,
            ) &&
            const DeepCollectionEquality().equals(
              other.skillsUsed,
              _this.skillsUsed,
            ) &&
            const DeepCollectionEquality().equals(
              other.counterattackNodes,
              _this.counterattackNodes,
            ) &&
            (identical(other.wonOnTurn, _this.wonOnTurn) ||
                other.wonOnTurn == _this.wonOnTurn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as MissionStats;
    return Object.hash(
      runtimeType,
      _this.troopsLost,
      _this.defections,
      _this.captures,
      _this.battlesWon,
      _this.battlesLost,
      _this.evacuations,
      _this.raids,
      _this.ambushesTriggered,
      const DeepCollectionEquality().hash(_this.cardsPlayed),
      const DeepCollectionEquality().hash(_this.skillsUsed),
      const DeepCollectionEquality().hash(_this.counterattackNodes),
      _this.wonOnTurn,
    );
  }

  @override
  String toString() {
    final _this = this as MissionStats;
    return 'MissionStats(troopsLost: ${_this.troopsLost}, defections: ${_this.defections}, captures: ${_this.captures}, battlesWon: ${_this.battlesWon}, battlesLost: ${_this.battlesLost}, evacuations: ${_this.evacuations}, raids: ${_this.raids}, ambushesTriggered: ${_this.ambushesTriggered}, cardsPlayed: ${_this.cardsPlayed}, skillsUsed: ${_this.skillsUsed}, counterattackNodes: ${_this.counterattackNodes}, wonOnTurn: ${_this.wonOnTurn})';
  }
}

/// @nodoc
abstract mixin class $MissionStatsCopyWith<$Res> {
  factory $MissionStatsCopyWith(
    MissionStats value,
    $Res Function(MissionStats) _then,
  ) = _$MissionStatsCopyWithImpl;
  @useResult
  $Res call({
    int troopsLost,
    int defections,
    int captures,
    int battlesWon,
    int battlesLost,
    int evacuations,
    int raids,
    int ambushesTriggered,
    Map<String, int> cardsPlayed,
    Map<String, int> skillsUsed,
    List<String> counterattackNodes,
    int? wonOnTurn,
  });
}

/// @nodoc
class _$MissionStatsCopyWithImpl<$Res> implements $MissionStatsCopyWith<$Res> {
  _$MissionStatsCopyWithImpl(this._self, this._then);

  final MissionStats _self;
  final $Res Function(MissionStats) _then;

  /// Create a copy of MissionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? troopsLost = null,
    Object? defections = null,
    Object? captures = null,
    Object? battlesWon = null,
    Object? battlesLost = null,
    Object? evacuations = null,
    Object? raids = null,
    Object? ambushesTriggered = null,
    Object? cardsPlayed = null,
    Object? skillsUsed = null,
    Object? counterattackNodes = null,
    Object? wonOnTurn = freezed,
  }) {
    return _then(
      MissionStats(
        troopsLost: null == troopsLost
            ? _self.troopsLost
            : troopsLost // ignore: cast_nullable_to_non_nullable
                  as int,
        defections: null == defections
            ? _self.defections
            : defections // ignore: cast_nullable_to_non_nullable
                  as int,
        captures: null == captures
            ? _self.captures
            : captures // ignore: cast_nullable_to_non_nullable
                  as int,
        battlesWon: null == battlesWon
            ? _self.battlesWon
            : battlesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        battlesLost: null == battlesLost
            ? _self.battlesLost
            : battlesLost // ignore: cast_nullable_to_non_nullable
                  as int,
        evacuations: null == evacuations
            ? _self.evacuations
            : evacuations // ignore: cast_nullable_to_non_nullable
                  as int,
        raids: null == raids
            ? _self.raids
            : raids // ignore: cast_nullable_to_non_nullable
                  as int,
        ambushesTriggered: null == ambushesTriggered
            ? _self.ambushesTriggered
            : ambushesTriggered // ignore: cast_nullable_to_non_nullable
                  as int,
        cardsPlayed: null == cardsPlayed
            ? _self.cardsPlayed
            : cardsPlayed // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        skillsUsed: null == skillsUsed
            ? _self.skillsUsed
            : skillsUsed // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        counterattackNodes: null == counterattackNodes
            ? _self.counterattackNodes
            : counterattackNodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        wonOnTurn: freezed == wonOnTurn
            ? _self.wonOnTurn
            : wonOnTurn // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [MissionStats].
extension MissionStatsPatterns on MissionStats {
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
    TResult Function(_MissionStats value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MissionStats() when $default != null:
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
    TResult Function(_MissionStats value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MissionStats():
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
    TResult? Function(_MissionStats value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MissionStats() when $default != null:
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
      int troopsLost,
      int defections,
      int captures,
      int battlesWon,
      int battlesLost,
      int evacuations,
      int raids,
      int ambushesTriggered,
      Map<String, int> cardsPlayed,
      Map<String, int> skillsUsed,
      List<String> counterattackNodes,
      int? wonOnTurn,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MissionStats() when $default != null:
        return $default(
          _that.troopsLost,
          _that.defections,
          _that.captures,
          _that.battlesWon,
          _that.battlesLost,
          _that.evacuations,
          _that.raids,
          _that.ambushesTriggered,
          _that.cardsPlayed,
          _that.skillsUsed,
          _that.counterattackNodes,
          _that.wonOnTurn,
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
      int troopsLost,
      int defections,
      int captures,
      int battlesWon,
      int battlesLost,
      int evacuations,
      int raids,
      int ambushesTriggered,
      Map<String, int> cardsPlayed,
      Map<String, int> skillsUsed,
      List<String> counterattackNodes,
      int? wonOnTurn,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MissionStats():
        return $default(
          _that.troopsLost,
          _that.defections,
          _that.captures,
          _that.battlesWon,
          _that.battlesLost,
          _that.evacuations,
          _that.raids,
          _that.ambushesTriggered,
          _that.cardsPlayed,
          _that.skillsUsed,
          _that.counterattackNodes,
          _that.wonOnTurn,
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
      int troopsLost,
      int defections,
      int captures,
      int battlesWon,
      int battlesLost,
      int evacuations,
      int raids,
      int ambushesTriggered,
      Map<String, int> cardsPlayed,
      Map<String, int> skillsUsed,
      List<String> counterattackNodes,
      int? wonOnTurn,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MissionStats() when $default != null:
        return $default(
          _that.troopsLost,
          _that.defections,
          _that.captures,
          _that.battlesWon,
          _that.battlesLost,
          _that.evacuations,
          _that.raids,
          _that.ambushesTriggered,
          _that.cardsPlayed,
          _that.skillsUsed,
          _that.counterattackNodes,
          _that.wonOnTurn,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MissionStats implements MissionStats {
  const _MissionStats({
    this.troopsLost = 0,
    this.defections = 0,
    this.captures = 0,
    this.battlesWon = 0,
    this.battlesLost = 0,
    this.evacuations = 0,
    this.raids = 0,
    this.ambushesTriggered = 0,
    Map<String, int> cardsPlayed = const <String, int>{},
    Map<String, int> skillsUsed = const <String, int>{},
    List<String> counterattackNodes = const <String>[],
    this.wonOnTurn,
  }) : _cardsPlayed = cardsPlayed,
       _skillsUsed = skillsUsed,
       _counterattackNodes = counterattackNodes;
  factory _MissionStats.fromJson(Map<String, dynamic> json) =>
      _$MissionStatsFromJson(json);

  @override
  @JsonKey()
  final int troopsLost;
  @override
  @JsonKey()
  final int defections;
  @override
  @JsonKey()
  final int captures;
  @override
  @JsonKey()
  final int battlesWon;
  @override
  @JsonKey()
  final int battlesLost;
  @override
  @JsonKey()
  final int evacuations;
  @override
  @JsonKey()
  final int raids;
  @override
  @JsonKey()
  final int ambushesTriggered;
  final Map<String, int> _cardsPlayed;
  @override
  @JsonKey()
  Map<String, int> get cardsPlayed {
    if (_cardsPlayed is EqualUnmodifiableMapView) return _cardsPlayed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cardsPlayed);
  }

  final Map<String, int> _skillsUsed;
  @override
  @JsonKey()
  Map<String, int> get skillsUsed {
    if (_skillsUsed is EqualUnmodifiableMapView) return _skillsUsed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_skillsUsed);
  }

  /// Nodes where a `counterattackAt` battle was won.
  final List<String> _counterattackNodes;

  /// Nodes where a `counterattackAt` battle was won.
  @override
  @JsonKey()
  List<String> get counterattackNodes {
    if (_counterattackNodes is EqualUnmodifiableListView)
      return _counterattackNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_counterattackNodes);
  }

  @override
  final int? wonOnTurn;

  /// Create a copy of MissionStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MissionStatsCopyWith<_MissionStats> get copyWith =>
      __$MissionStatsCopyWithImpl<_MissionStats>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MissionStatsToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MissionStats &&
            (identical(other.troopsLost, troopsLost) ||
                other.troopsLost == troopsLost) &&
            (identical(other.defections, defections) ||
                other.defections == defections) &&
            (identical(other.captures, captures) ||
                other.captures == captures) &&
            (identical(other.battlesWon, battlesWon) ||
                other.battlesWon == battlesWon) &&
            (identical(other.battlesLost, battlesLost) ||
                other.battlesLost == battlesLost) &&
            (identical(other.evacuations, evacuations) ||
                other.evacuations == evacuations) &&
            (identical(other.raids, raids) || other.raids == raids) &&
            (identical(other.ambushesTriggered, ambushesTriggered) ||
                other.ambushesTriggered == ambushesTriggered) &&
            const DeepCollectionEquality().equals(
              other.cardsPlayed,
              _cardsPlayed,
            ) &&
            const DeepCollectionEquality().equals(
              other.skillsUsed,
              _skillsUsed,
            ) &&
            const DeepCollectionEquality().equals(
              other.counterattackNodes,
              _counterattackNodes,
            ) &&
            (identical(other.wonOnTurn, wonOnTurn) ||
                other.wonOnTurn == wonOnTurn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      troopsLost,
      defections,
      captures,
      battlesWon,
      battlesLost,
      evacuations,
      raids,
      ambushesTriggered,
      const DeepCollectionEquality().hash(_cardsPlayed),
      const DeepCollectionEquality().hash(_skillsUsed),
      const DeepCollectionEquality().hash(_counterattackNodes),
      wonOnTurn,
    );
  }

  @override
  String toString() {
    return 'MissionStats(troopsLost: $troopsLost, defections: $defections, captures: $captures, battlesWon: $battlesWon, battlesLost: $battlesLost, evacuations: $evacuations, raids: $raids, ambushesTriggered: $ambushesTriggered, cardsPlayed: $cardsPlayed, skillsUsed: $skillsUsed, counterattackNodes: $counterattackNodes, wonOnTurn: $wonOnTurn)';
  }
}

/// @nodoc
abstract mixin class _$MissionStatsCopyWith<$Res>
    implements $MissionStatsCopyWith<$Res> {
  factory _$MissionStatsCopyWith(
    _MissionStats value,
    $Res Function(_MissionStats) _then,
  ) = __$MissionStatsCopyWithImpl;
  @override
  @useResult
  $Res call({
    int troopsLost,
    int defections,
    int captures,
    int battlesWon,
    int battlesLost,
    int evacuations,
    int raids,
    int ambushesTriggered,
    Map<String, int> cardsPlayed,
    Map<String, int> skillsUsed,
    List<String> counterattackNodes,
    int? wonOnTurn,
  });
}

/// @nodoc
class __$MissionStatsCopyWithImpl<$Res>
    implements _$MissionStatsCopyWith<$Res> {
  __$MissionStatsCopyWithImpl(this._self, this._then);

  final _MissionStats _self;
  final $Res Function(_MissionStats) _then;

  /// Create a copy of MissionStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? troopsLost = null,
    Object? defections = null,
    Object? captures = null,
    Object? battlesWon = null,
    Object? battlesLost = null,
    Object? evacuations = null,
    Object? raids = null,
    Object? ambushesTriggered = null,
    Object? cardsPlayed = null,
    Object? skillsUsed = null,
    Object? counterattackNodes = null,
    Object? wonOnTurn = freezed,
  }) {
    return _then(
      _MissionStats(
        troopsLost: null == troopsLost
            ? _self.troopsLost
            : troopsLost // ignore: cast_nullable_to_non_nullable
                  as int,
        defections: null == defections
            ? _self.defections
            : defections // ignore: cast_nullable_to_non_nullable
                  as int,
        captures: null == captures
            ? _self.captures
            : captures // ignore: cast_nullable_to_non_nullable
                  as int,
        battlesWon: null == battlesWon
            ? _self.battlesWon
            : battlesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        battlesLost: null == battlesLost
            ? _self.battlesLost
            : battlesLost // ignore: cast_nullable_to_non_nullable
                  as int,
        evacuations: null == evacuations
            ? _self.evacuations
            : evacuations // ignore: cast_nullable_to_non_nullable
                  as int,
        raids: null == raids
            ? _self.raids
            : raids // ignore: cast_nullable_to_non_nullable
                  as int,
        ambushesTriggered: null == ambushesTriggered
            ? _self.ambushesTriggered
            : ambushesTriggered // ignore: cast_nullable_to_non_nullable
                  as int,
        cardsPlayed: null == cardsPlayed
            ? _self._cardsPlayed
            : cardsPlayed // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        skillsUsed: null == skillsUsed
            ? _self._skillsUsed
            : skillsUsed // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        counterattackNodes: null == counterattackNodes
            ? _self._counterattackNodes
            : counterattackNodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        wonOnTurn: freezed == wonOnTurn
            ? _self.wonOnTurn
            : wonOnTurn // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
mixin _$GameState {
  String get missionId;
  int get seed;

  /// SplitMix64 state of the game's [SeededRng].
  int get rng;
  int get turn;
  Phase get phase;
  Outcome? get outcome;
  String? get lossReason;
  int get rice;
  int get support;
  Unity get unity;
  Map<String, NodeState> get nodes;
  Map<String, OfficerState> get officers;
  Map<String, ArmyState> get armies;
  List<Ambush> get ambushes;
  List<String> get deck;
  List<String> get hand;
  List<String> get discard;
  PendingChoice? get pendingChoice;

  /// Free play: after the mission ended the player kept playing, until
  /// either side has no troops left. [outcome] stays the mission's own
  /// result; [freePlayOutcome] is how the free play itself ended.
  bool get freePlay;
  Outcome? get freePlayOutcome;

  /// The phase the mission ended in, so that free play can carry on from there.
  Phase? get endedIn;

  /// Scripted event cards of this turn still waiting behind a choice.
  List<String> get scriptedQueue;
  int get revealDepth;

  /// Mission flags, e.g. [GameFlags.capitalLost].
  List<String> get flags;
  int get evacuationsThisTurn;
  MissionStats get missionStats;

  /// Stars earned, one entry per star objective; set when the mission is won.
  List<bool> get stars;

  /// Every action applied since the mission start (the save file's log).
  List<GameAction> get log;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameStateCopyWith<GameState> get copyWith =>
      _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as GameState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameState &&
            (identical(other.missionId, _this.missionId) ||
                other.missionId == _this.missionId) &&
            (identical(other.seed, _this.seed) || other.seed == _this.seed) &&
            (identical(other.rng, _this.rng) || other.rng == _this.rng) &&
            (identical(other.turn, _this.turn) || other.turn == _this.turn) &&
            (identical(other.phase, _this.phase) ||
                other.phase == _this.phase) &&
            (identical(other.outcome, _this.outcome) ||
                other.outcome == _this.outcome) &&
            (identical(other.lossReason, _this.lossReason) ||
                other.lossReason == _this.lossReason) &&
            (identical(other.rice, _this.rice) || other.rice == _this.rice) &&
            (identical(other.support, _this.support) ||
                other.support == _this.support) &&
            (identical(other.unity, _this.unity) ||
                other.unity == _this.unity) &&
            const DeepCollectionEquality().equals(other.nodes, _this.nodes) &&
            const DeepCollectionEquality().equals(
              other.officers,
              _this.officers,
            ) &&
            const DeepCollectionEquality().equals(other.armies, _this.armies) &&
            const DeepCollectionEquality().equals(
              other.ambushes,
              _this.ambushes,
            ) &&
            const DeepCollectionEquality().equals(other.deck, _this.deck) &&
            const DeepCollectionEquality().equals(other.hand, _this.hand) &&
            const DeepCollectionEquality().equals(
              other.discard,
              _this.discard,
            ) &&
            (identical(other.pendingChoice, _this.pendingChoice) ||
                other.pendingChoice == _this.pendingChoice) &&
            (identical(other.freePlay, _this.freePlay) ||
                other.freePlay == _this.freePlay) &&
            (identical(other.freePlayOutcome, _this.freePlayOutcome) ||
                other.freePlayOutcome == _this.freePlayOutcome) &&
            (identical(other.endedIn, _this.endedIn) ||
                other.endedIn == _this.endedIn) &&
            const DeepCollectionEquality().equals(
              other.scriptedQueue,
              _this.scriptedQueue,
            ) &&
            (identical(other.revealDepth, _this.revealDepth) ||
                other.revealDepth == _this.revealDepth) &&
            const DeepCollectionEquality().equals(other.flags, _this.flags) &&
            (identical(other.evacuationsThisTurn, _this.evacuationsThisTurn) ||
                other.evacuationsThisTurn == _this.evacuationsThisTurn) &&
            (identical(other.missionStats, _this.missionStats) ||
                other.missionStats == _this.missionStats) &&
            const DeepCollectionEquality().equals(other.stars, _this.stars) &&
            const DeepCollectionEquality().equals(other.log, _this.log));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as GameState;
    return Object.hashAll([
      runtimeType,
      _this.missionId,
      _this.seed,
      _this.rng,
      _this.turn,
      _this.phase,
      _this.outcome,
      _this.lossReason,
      _this.rice,
      _this.support,
      _this.unity,
      const DeepCollectionEquality().hash(_this.nodes),
      const DeepCollectionEquality().hash(_this.officers),
      const DeepCollectionEquality().hash(_this.armies),
      const DeepCollectionEquality().hash(_this.ambushes),
      const DeepCollectionEquality().hash(_this.deck),
      const DeepCollectionEquality().hash(_this.hand),
      const DeepCollectionEquality().hash(_this.discard),
      _this.pendingChoice,
      _this.freePlay,
      _this.freePlayOutcome,
      _this.endedIn,
      const DeepCollectionEquality().hash(_this.scriptedQueue),
      _this.revealDepth,
      const DeepCollectionEquality().hash(_this.flags),
      _this.evacuationsThisTurn,
      _this.missionStats,
      const DeepCollectionEquality().hash(_this.stars),
      const DeepCollectionEquality().hash(_this.log),
    ]);
  }

  @override
  String toString() {
    final _this = this as GameState;
    return 'GameState(missionId: ${_this.missionId}, seed: ${_this.seed}, rng: ${_this.rng}, turn: ${_this.turn}, phase: ${_this.phase}, outcome: ${_this.outcome}, lossReason: ${_this.lossReason}, rice: ${_this.rice}, support: ${_this.support}, unity: ${_this.unity}, nodes: ${_this.nodes}, officers: ${_this.officers}, armies: ${_this.armies}, ambushes: ${_this.ambushes}, deck: ${_this.deck}, hand: ${_this.hand}, discard: ${_this.discard}, pendingChoice: ${_this.pendingChoice}, freePlay: ${_this.freePlay}, freePlayOutcome: ${_this.freePlayOutcome}, endedIn: ${_this.endedIn}, scriptedQueue: ${_this.scriptedQueue}, revealDepth: ${_this.revealDepth}, flags: ${_this.flags}, evacuationsThisTurn: ${_this.evacuationsThisTurn}, missionStats: ${_this.missionStats}, stars: ${_this.stars}, log: ${_this.log})';
  }
}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) =
      _$GameStateCopyWithImpl;
  @useResult
  $Res call({
    String missionId,
    int seed,
    int rng,
    int turn,
    Phase phase,
    Outcome? outcome,
    String? lossReason,
    int rice,
    int support,
    Unity unity,
    Map<String, NodeState> nodes,
    Map<String, OfficerState> officers,
    Map<String, ArmyState> armies,
    List<Ambush> ambushes,
    List<String> deck,
    List<String> hand,
    List<String> discard,
    PendingChoice? pendingChoice,
    bool freePlay,
    Outcome? freePlayOutcome,
    Phase? endedIn,
    List<String> scriptedQueue,
    int revealDepth,
    List<String> flags,
    int evacuationsThisTurn,
    MissionStats missionStats,
    List<bool> stars,
    List<GameAction> log,
  });

  $UnityCopyWith<$Res> get unity;
  $PendingChoiceCopyWith<$Res>? get pendingChoice;
  $MissionStatsCopyWith<$Res> get missionStats;
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res> implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? missionId = null,
    Object? seed = null,
    Object? rng = null,
    Object? turn = null,
    Object? phase = null,
    Object? outcome = freezed,
    Object? lossReason = freezed,
    Object? rice = null,
    Object? support = null,
    Object? unity = null,
    Object? nodes = null,
    Object? officers = null,
    Object? armies = null,
    Object? ambushes = null,
    Object? deck = null,
    Object? hand = null,
    Object? discard = null,
    Object? pendingChoice = freezed,
    Object? freePlay = null,
    Object? freePlayOutcome = freezed,
    Object? endedIn = freezed,
    Object? scriptedQueue = null,
    Object? revealDepth = null,
    Object? flags = null,
    Object? evacuationsThisTurn = null,
    Object? missionStats = null,
    Object? stars = null,
    Object? log = null,
  }) {
    return _then(
      GameState(
        missionId: null == missionId
            ? _self.missionId
            : missionId // ignore: cast_nullable_to_non_nullable
                  as String,
        seed: null == seed
            ? _self.seed
            : seed // ignore: cast_nullable_to_non_nullable
                  as int,
        rng: null == rng
            ? _self.rng
            : rng // ignore: cast_nullable_to_non_nullable
                  as int,
        turn: null == turn
            ? _self.turn
            : turn // ignore: cast_nullable_to_non_nullable
                  as int,
        phase: null == phase
            ? _self.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as Phase,
        outcome: freezed == outcome
            ? _self.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as Outcome?,
        lossReason: freezed == lossReason
            ? _self.lossReason
            : lossReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        rice: null == rice
            ? _self.rice
            : rice // ignore: cast_nullable_to_non_nullable
                  as int,
        support: null == support
            ? _self.support
            : support // ignore: cast_nullable_to_non_nullable
                  as int,
        unity: null == unity
            ? _self.unity
            : unity // ignore: cast_nullable_to_non_nullable
                  as Unity,
        nodes: null == nodes
            ? _self.nodes
            : nodes // ignore: cast_nullable_to_non_nullable
                  as Map<String, NodeState>,
        officers: null == officers
            ? _self.officers
            : officers // ignore: cast_nullable_to_non_nullable
                  as Map<String, OfficerState>,
        armies: null == armies
            ? _self.armies
            : armies // ignore: cast_nullable_to_non_nullable
                  as Map<String, ArmyState>,
        ambushes: null == ambushes
            ? _self.ambushes
            : ambushes // ignore: cast_nullable_to_non_nullable
                  as List<Ambush>,
        deck: null == deck
            ? _self.deck
            : deck // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hand: null == hand
            ? _self.hand
            : hand // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        discard: null == discard
            ? _self.discard
            : discard // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        pendingChoice: freezed == pendingChoice
            ? _self.pendingChoice
            : pendingChoice // ignore: cast_nullable_to_non_nullable
                  as PendingChoice?,
        freePlay: null == freePlay
            ? _self.freePlay
            : freePlay // ignore: cast_nullable_to_non_nullable
                  as bool,
        freePlayOutcome: freezed == freePlayOutcome
            ? _self.freePlayOutcome
            : freePlayOutcome // ignore: cast_nullable_to_non_nullable
                  as Outcome?,
        endedIn: freezed == endedIn
            ? _self.endedIn
            : endedIn // ignore: cast_nullable_to_non_nullable
                  as Phase?,
        scriptedQueue: null == scriptedQueue
            ? _self.scriptedQueue
            : scriptedQueue // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        revealDepth: null == revealDepth
            ? _self.revealDepth
            : revealDepth // ignore: cast_nullable_to_non_nullable
                  as int,
        flags: null == flags
            ? _self.flags
            : flags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        evacuationsThisTurn: null == evacuationsThisTurn
            ? _self.evacuationsThisTurn
            : evacuationsThisTurn // ignore: cast_nullable_to_non_nullable
                  as int,
        missionStats: null == missionStats
            ? _self.missionStats
            : missionStats // ignore: cast_nullable_to_non_nullable
                  as MissionStats,
        stars: null == stars
            ? _self.stars
            : stars // ignore: cast_nullable_to_non_nullable
                  as List<bool>,
        log: null == log
            ? _self.log
            : log // ignore: cast_nullable_to_non_nullable
                  as List<GameAction>,
      ),
    );
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UnityCopyWith<$Res> get unity {
    return $UnityCopyWith<$Res>(_self.unity, (value) {
      return _then(_self.copyWith(unity: value));
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PendingChoiceCopyWith<$Res>? get pendingChoice {
    if (_self.pendingChoice == null) {
      return null;
    }

    return $PendingChoiceCopyWith<$Res>(_self.pendingChoice!, (value) {
      return _then(_self.copyWith(pendingChoice: value));
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MissionStatsCopyWith<$Res> get missionStats {
    return $MissionStatsCopyWith<$Res>(_self.missionStats, (value) {
      return _then(_self.copyWith(missionStats: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
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
    TResult Function(_GameState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
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
    TResult Function(_GameState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState():
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
    TResult? Function(_GameState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
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
      String missionId,
      int seed,
      int rng,
      int turn,
      Phase phase,
      Outcome? outcome,
      String? lossReason,
      int rice,
      int support,
      Unity unity,
      Map<String, NodeState> nodes,
      Map<String, OfficerState> officers,
      Map<String, ArmyState> armies,
      List<Ambush> ambushes,
      List<String> deck,
      List<String> hand,
      List<String> discard,
      PendingChoice? pendingChoice,
      bool freePlay,
      Outcome? freePlayOutcome,
      Phase? endedIn,
      List<String> scriptedQueue,
      int revealDepth,
      List<String> flags,
      int evacuationsThisTurn,
      MissionStats missionStats,
      List<bool> stars,
      List<GameAction> log,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(
          _that.missionId,
          _that.seed,
          _that.rng,
          _that.turn,
          _that.phase,
          _that.outcome,
          _that.lossReason,
          _that.rice,
          _that.support,
          _that.unity,
          _that.nodes,
          _that.officers,
          _that.armies,
          _that.ambushes,
          _that.deck,
          _that.hand,
          _that.discard,
          _that.pendingChoice,
          _that.freePlay,
          _that.freePlayOutcome,
          _that.endedIn,
          _that.scriptedQueue,
          _that.revealDepth,
          _that.flags,
          _that.evacuationsThisTurn,
          _that.missionStats,
          _that.stars,
          _that.log,
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
      String missionId,
      int seed,
      int rng,
      int turn,
      Phase phase,
      Outcome? outcome,
      String? lossReason,
      int rice,
      int support,
      Unity unity,
      Map<String, NodeState> nodes,
      Map<String, OfficerState> officers,
      Map<String, ArmyState> armies,
      List<Ambush> ambushes,
      List<String> deck,
      List<String> hand,
      List<String> discard,
      PendingChoice? pendingChoice,
      bool freePlay,
      Outcome? freePlayOutcome,
      Phase? endedIn,
      List<String> scriptedQueue,
      int revealDepth,
      List<String> flags,
      int evacuationsThisTurn,
      MissionStats missionStats,
      List<bool> stars,
      List<GameAction> log,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState():
        return $default(
          _that.missionId,
          _that.seed,
          _that.rng,
          _that.turn,
          _that.phase,
          _that.outcome,
          _that.lossReason,
          _that.rice,
          _that.support,
          _that.unity,
          _that.nodes,
          _that.officers,
          _that.armies,
          _that.ambushes,
          _that.deck,
          _that.hand,
          _that.discard,
          _that.pendingChoice,
          _that.freePlay,
          _that.freePlayOutcome,
          _that.endedIn,
          _that.scriptedQueue,
          _that.revealDepth,
          _that.flags,
          _that.evacuationsThisTurn,
          _that.missionStats,
          _that.stars,
          _that.log,
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
      String missionId,
      int seed,
      int rng,
      int turn,
      Phase phase,
      Outcome? outcome,
      String? lossReason,
      int rice,
      int support,
      Unity unity,
      Map<String, NodeState> nodes,
      Map<String, OfficerState> officers,
      Map<String, ArmyState> armies,
      List<Ambush> ambushes,
      List<String> deck,
      List<String> hand,
      List<String> discard,
      PendingChoice? pendingChoice,
      bool freePlay,
      Outcome? freePlayOutcome,
      Phase? endedIn,
      List<String> scriptedQueue,
      int revealDepth,
      List<String> flags,
      int evacuationsThisTurn,
      MissionStats missionStats,
      List<bool> stars,
      List<GameAction> log,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(
          _that.missionId,
          _that.seed,
          _that.rng,
          _that.turn,
          _that.phase,
          _that.outcome,
          _that.lossReason,
          _that.rice,
          _that.support,
          _that.unity,
          _that.nodes,
          _that.officers,
          _that.armies,
          _that.ambushes,
          _that.deck,
          _that.hand,
          _that.discard,
          _that.pendingChoice,
          _that.freePlay,
          _that.freePlayOutcome,
          _that.endedIn,
          _that.scriptedQueue,
          _that.revealDepth,
          _that.flags,
          _that.evacuationsThisTurn,
          _that.missionStats,
          _that.stars,
          _that.log,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GameState extends GameState {
  const _GameState({
    required this.missionId,
    required this.seed,
    required this.rng,
    required this.turn,
    required this.phase,
    this.outcome,
    this.lossReason,
    required this.rice,
    required this.support,
    required this.unity,
    required Map<String, NodeState> nodes,
    required Map<String, OfficerState> officers,
    required Map<String, ArmyState> armies,
    List<Ambush> ambushes = const <Ambush>[],
    List<String> deck = const <String>[],
    List<String> hand = const <String>[],
    List<String> discard = const <String>[],
    this.pendingChoice,
    this.freePlay = false,
    this.freePlayOutcome,
    this.endedIn,
    List<String> scriptedQueue = const <String>[],
    this.revealDepth = 1,
    List<String> flags = const <String>[],
    this.evacuationsThisTurn = 0,
    this.missionStats = const MissionStats(),
    List<bool> stars = const <bool>[],
    List<GameAction> log = const <GameAction>[],
  }) : _nodes = nodes,
       _officers = officers,
       _armies = armies,
       _ambushes = ambushes,
       _deck = deck,
       _hand = hand,
       _discard = discard,
       _scriptedQueue = scriptedQueue,
       _flags = flags,
       _stars = stars,
       _log = log,
       super._();
  factory _GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  @override
  final String missionId;
  @override
  final int seed;

  /// SplitMix64 state of the game's [SeededRng].
  @override
  final int rng;
  @override
  final int turn;
  @override
  final Phase phase;
  @override
  final Outcome? outcome;
  @override
  final String? lossReason;
  @override
  final int rice;
  @override
  final int support;
  @override
  final Unity unity;
  final Map<String, NodeState> _nodes;
  @override
  Map<String, NodeState> get nodes {
    if (_nodes is EqualUnmodifiableMapView) return _nodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nodes);
  }

  final Map<String, OfficerState> _officers;
  @override
  Map<String, OfficerState> get officers {
    if (_officers is EqualUnmodifiableMapView) return _officers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_officers);
  }

  final Map<String, ArmyState> _armies;
  @override
  Map<String, ArmyState> get armies {
    if (_armies is EqualUnmodifiableMapView) return _armies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_armies);
  }

  final List<Ambush> _ambushes;
  @override
  @JsonKey()
  List<Ambush> get ambushes {
    if (_ambushes is EqualUnmodifiableListView) return _ambushes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ambushes);
  }

  final List<String> _deck;
  @override
  @JsonKey()
  List<String> get deck {
    if (_deck is EqualUnmodifiableListView) return _deck;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deck);
  }

  final List<String> _hand;
  @override
  @JsonKey()
  List<String> get hand {
    if (_hand is EqualUnmodifiableListView) return _hand;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hand);
  }

  final List<String> _discard;
  @override
  @JsonKey()
  List<String> get discard {
    if (_discard is EqualUnmodifiableListView) return _discard;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_discard);
  }

  @override
  final PendingChoice? pendingChoice;

  /// Free play: after the mission ended the player kept playing, until
  /// either side has no troops left. [outcome] stays the mission's own
  /// result; [freePlayOutcome] is how the free play itself ended.
  @override
  @JsonKey()
  final bool freePlay;
  @override
  final Outcome? freePlayOutcome;

  /// The phase the mission ended in, so that free play can carry on from there.
  @override
  final Phase? endedIn;

  /// Scripted event cards of this turn still waiting behind a choice.
  final List<String> _scriptedQueue;

  /// Scripted event cards of this turn still waiting behind a choice.
  @override
  @JsonKey()
  List<String> get scriptedQueue {
    if (_scriptedQueue is EqualUnmodifiableListView) return _scriptedQueue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scriptedQueue);
  }

  @override
  @JsonKey()
  final int revealDepth;

  /// Mission flags, e.g. [GameFlags.capitalLost].
  final List<String> _flags;

  /// Mission flags, e.g. [GameFlags.capitalLost].
  @override
  @JsonKey()
  List<String> get flags {
    if (_flags is EqualUnmodifiableListView) return _flags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_flags);
  }

  @override
  @JsonKey()
  final int evacuationsThisTurn;
  @override
  @JsonKey()
  final MissionStats missionStats;

  /// Stars earned, one entry per star objective; set when the mission is won.
  final List<bool> _stars;

  /// Stars earned, one entry per star objective; set when the mission is won.
  @override
  @JsonKey()
  List<bool> get stars {
    if (_stars is EqualUnmodifiableListView) return _stars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stars);
  }

  /// Every action applied since the mission start (the save file's log).
  final List<GameAction> _log;

  /// Every action applied since the mission start (the save file's log).
  @override
  @JsonKey()
  List<GameAction> get log {
    if (_log is EqualUnmodifiableListView) return _log;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_log);
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameStateCopyWith<_GameState> get copyWith =>
      __$GameStateCopyWithImpl<_GameState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GameStateToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GameState &&
            (identical(other.missionId, missionId) ||
                other.missionId == missionId) &&
            (identical(other.seed, seed) || other.seed == seed) &&
            (identical(other.rng, rng) || other.rng == rng) &&
            (identical(other.turn, turn) || other.turn == turn) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.lossReason, lossReason) ||
                other.lossReason == lossReason) &&
            (identical(other.rice, rice) || other.rice == rice) &&
            (identical(other.support, support) || other.support == support) &&
            (identical(other.unity, unity) || other.unity == unity) &&
            const DeepCollectionEquality().equals(other.nodes, _nodes) &&
            const DeepCollectionEquality().equals(other.officers, _officers) &&
            const DeepCollectionEquality().equals(other.armies, _armies) &&
            const DeepCollectionEquality().equals(other.ambushes, _ambushes) &&
            const DeepCollectionEquality().equals(other.deck, _deck) &&
            const DeepCollectionEquality().equals(other.hand, _hand) &&
            const DeepCollectionEquality().equals(other.discard, _discard) &&
            (identical(other.pendingChoice, pendingChoice) ||
                other.pendingChoice == pendingChoice) &&
            (identical(other.freePlay, freePlay) ||
                other.freePlay == freePlay) &&
            (identical(other.freePlayOutcome, freePlayOutcome) ||
                other.freePlayOutcome == freePlayOutcome) &&
            (identical(other.endedIn, endedIn) || other.endedIn == endedIn) &&
            const DeepCollectionEquality().equals(
              other.scriptedQueue,
              _scriptedQueue,
            ) &&
            (identical(other.revealDepth, revealDepth) ||
                other.revealDepth == revealDepth) &&
            const DeepCollectionEquality().equals(other.flags, _flags) &&
            (identical(other.evacuationsThisTurn, evacuationsThisTurn) ||
                other.evacuationsThisTurn == evacuationsThisTurn) &&
            (identical(other.missionStats, missionStats) ||
                other.missionStats == missionStats) &&
            const DeepCollectionEquality().equals(other.stars, _stars) &&
            const DeepCollectionEquality().equals(other.log, _log));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hashAll([
      runtimeType,
      missionId,
      seed,
      rng,
      turn,
      phase,
      outcome,
      lossReason,
      rice,
      support,
      unity,
      const DeepCollectionEquality().hash(_nodes),
      const DeepCollectionEquality().hash(_officers),
      const DeepCollectionEquality().hash(_armies),
      const DeepCollectionEquality().hash(_ambushes),
      const DeepCollectionEquality().hash(_deck),
      const DeepCollectionEquality().hash(_hand),
      const DeepCollectionEquality().hash(_discard),
      pendingChoice,
      freePlay,
      freePlayOutcome,
      endedIn,
      const DeepCollectionEquality().hash(_scriptedQueue),
      revealDepth,
      const DeepCollectionEquality().hash(_flags),
      evacuationsThisTurn,
      missionStats,
      const DeepCollectionEquality().hash(_stars),
      const DeepCollectionEquality().hash(_log),
    ]);
  }

  @override
  String toString() {
    return 'GameState(missionId: $missionId, seed: $seed, rng: $rng, turn: $turn, phase: $phase, outcome: $outcome, lossReason: $lossReason, rice: $rice, support: $support, unity: $unity, nodes: $nodes, officers: $officers, armies: $armies, ambushes: $ambushes, deck: $deck, hand: $hand, discard: $discard, pendingChoice: $pendingChoice, freePlay: $freePlay, freePlayOutcome: $freePlayOutcome, endedIn: $endedIn, scriptedQueue: $scriptedQueue, revealDepth: $revealDepth, flags: $flags, evacuationsThisTurn: $evacuationsThisTurn, missionStats: $missionStats, stars: $stars, log: $log)';
  }
}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(
    _GameState value,
    $Res Function(_GameState) _then,
  ) = __$GameStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    String missionId,
    int seed,
    int rng,
    int turn,
    Phase phase,
    Outcome? outcome,
    String? lossReason,
    int rice,
    int support,
    Unity unity,
    Map<String, NodeState> nodes,
    Map<String, OfficerState> officers,
    Map<String, ArmyState> armies,
    List<Ambush> ambushes,
    List<String> deck,
    List<String> hand,
    List<String> discard,
    PendingChoice? pendingChoice,
    bool freePlay,
    Outcome? freePlayOutcome,
    Phase? endedIn,
    List<String> scriptedQueue,
    int revealDepth,
    List<String> flags,
    int evacuationsThisTurn,
    MissionStats missionStats,
    List<bool> stars,
    List<GameAction> log,
  });

  @override
  $UnityCopyWith<$Res> get unity;
  @override
  $PendingChoiceCopyWith<$Res>? get pendingChoice;
  @override
  $MissionStatsCopyWith<$Res> get missionStats;
}

/// @nodoc
class __$GameStateCopyWithImpl<$Res> implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? missionId = null,
    Object? seed = null,
    Object? rng = null,
    Object? turn = null,
    Object? phase = null,
    Object? outcome = freezed,
    Object? lossReason = freezed,
    Object? rice = null,
    Object? support = null,
    Object? unity = null,
    Object? nodes = null,
    Object? officers = null,
    Object? armies = null,
    Object? ambushes = null,
    Object? deck = null,
    Object? hand = null,
    Object? discard = null,
    Object? pendingChoice = freezed,
    Object? freePlay = null,
    Object? freePlayOutcome = freezed,
    Object? endedIn = freezed,
    Object? scriptedQueue = null,
    Object? revealDepth = null,
    Object? flags = null,
    Object? evacuationsThisTurn = null,
    Object? missionStats = null,
    Object? stars = null,
    Object? log = null,
  }) {
    return _then(
      _GameState(
        missionId: null == missionId
            ? _self.missionId
            : missionId // ignore: cast_nullable_to_non_nullable
                  as String,
        seed: null == seed
            ? _self.seed
            : seed // ignore: cast_nullable_to_non_nullable
                  as int,
        rng: null == rng
            ? _self.rng
            : rng // ignore: cast_nullable_to_non_nullable
                  as int,
        turn: null == turn
            ? _self.turn
            : turn // ignore: cast_nullable_to_non_nullable
                  as int,
        phase: null == phase
            ? _self.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as Phase,
        outcome: freezed == outcome
            ? _self.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as Outcome?,
        lossReason: freezed == lossReason
            ? _self.lossReason
            : lossReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        rice: null == rice
            ? _self.rice
            : rice // ignore: cast_nullable_to_non_nullable
                  as int,
        support: null == support
            ? _self.support
            : support // ignore: cast_nullable_to_non_nullable
                  as int,
        unity: null == unity
            ? _self.unity
            : unity // ignore: cast_nullable_to_non_nullable
                  as Unity,
        nodes: null == nodes
            ? _self._nodes
            : nodes // ignore: cast_nullable_to_non_nullable
                  as Map<String, NodeState>,
        officers: null == officers
            ? _self._officers
            : officers // ignore: cast_nullable_to_non_nullable
                  as Map<String, OfficerState>,
        armies: null == armies
            ? _self._armies
            : armies // ignore: cast_nullable_to_non_nullable
                  as Map<String, ArmyState>,
        ambushes: null == ambushes
            ? _self._ambushes
            : ambushes // ignore: cast_nullable_to_non_nullable
                  as List<Ambush>,
        deck: null == deck
            ? _self._deck
            : deck // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hand: null == hand
            ? _self._hand
            : hand // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        discard: null == discard
            ? _self._discard
            : discard // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        pendingChoice: freezed == pendingChoice
            ? _self.pendingChoice
            : pendingChoice // ignore: cast_nullable_to_non_nullable
                  as PendingChoice?,
        freePlay: null == freePlay
            ? _self.freePlay
            : freePlay // ignore: cast_nullable_to_non_nullable
                  as bool,
        freePlayOutcome: freezed == freePlayOutcome
            ? _self.freePlayOutcome
            : freePlayOutcome // ignore: cast_nullable_to_non_nullable
                  as Outcome?,
        endedIn: freezed == endedIn
            ? _self.endedIn
            : endedIn // ignore: cast_nullable_to_non_nullable
                  as Phase?,
        scriptedQueue: null == scriptedQueue
            ? _self._scriptedQueue
            : scriptedQueue // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        revealDepth: null == revealDepth
            ? _self.revealDepth
            : revealDepth // ignore: cast_nullable_to_non_nullable
                  as int,
        flags: null == flags
            ? _self._flags
            : flags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        evacuationsThisTurn: null == evacuationsThisTurn
            ? _self.evacuationsThisTurn
            : evacuationsThisTurn // ignore: cast_nullable_to_non_nullable
                  as int,
        missionStats: null == missionStats
            ? _self.missionStats
            : missionStats // ignore: cast_nullable_to_non_nullable
                  as MissionStats,
        stars: null == stars
            ? _self._stars
            : stars // ignore: cast_nullable_to_non_nullable
                  as List<bool>,
        log: null == log
            ? _self._log
            : log // ignore: cast_nullable_to_non_nullable
                  as List<GameAction>,
      ),
    );
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UnityCopyWith<$Res> get unity {
    return $UnityCopyWith<$Res>(_self.unity, (value) {
      return _then(_self.copyWith(unity: value));
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PendingChoiceCopyWith<$Res>? get pendingChoice {
    if (_self.pendingChoice == null) {
      return null;
    }

    return $PendingChoiceCopyWith<$Res>(_self.pendingChoice!, (value) {
      return _then(_self.copyWith(pendingChoice: value));
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MissionStatsCopyWith<$Res> get missionStats {
    return $MissionStatsCopyWith<$Res>(_self.missionStats, (value) {
      return _then(_self.copyWith(missionStats: value));
    });
  }
}
