// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;
GameAction _$GameActionFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'playCard':
      return PlayCard.fromJson(json);
    case 'useSkill':
      return UseSkill.fromJson(json);
    case 'resolveChoice':
      return ResolveChoice.fromJson(json);
    case 'setOrder':
      return SetOrder.fromJson(json);
    case 'clearOrder':
      return ClearOrder.fromJson(json);
    case 'endPhase':
      return EndPhase.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'GameAction',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$GameAction {
  /// Serializes this GameAction to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is GameAction);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GameAction()';
  }
}

/// @nodoc
class $GameActionCopyWith<$Res> {
  $GameActionCopyWith(GameAction _, $Res Function(GameAction) __);
}

/// Adds pattern-matching-related methods to [GameAction].
extension GameActionPatterns on GameAction {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PlayCard value)? playCard,
    TResult Function(UseSkill value)? useSkill,
    TResult Function(ResolveChoice value)? resolveChoice,
    TResult Function(SetOrder value)? setOrder,
    TResult Function(ClearOrder value)? clearOrder,
    TResult Function(EndPhase value)? endPhase,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PlayCard() when playCard != null:
        return playCard(_that);
      case UseSkill() when useSkill != null:
        return useSkill(_that);
      case ResolveChoice() when resolveChoice != null:
        return resolveChoice(_that);
      case SetOrder() when setOrder != null:
        return setOrder(_that);
      case ClearOrder() when clearOrder != null:
        return clearOrder(_that);
      case EndPhase() when endPhase != null:
        return endPhase(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(PlayCard value) playCard,
    required TResult Function(UseSkill value) useSkill,
    required TResult Function(ResolveChoice value) resolveChoice,
    required TResult Function(SetOrder value) setOrder,
    required TResult Function(ClearOrder value) clearOrder,
    required TResult Function(EndPhase value) endPhase,
  }) {
    final _that = this;
    switch (_that) {
      case PlayCard():
        return playCard(_that);
      case UseSkill():
        return useSkill(_that);
      case ResolveChoice():
        return resolveChoice(_that);
      case SetOrder():
        return setOrder(_that);
      case ClearOrder():
        return clearOrder(_that);
      case EndPhase():
        return endPhase(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PlayCard value)? playCard,
    TResult? Function(UseSkill value)? useSkill,
    TResult? Function(ResolveChoice value)? resolveChoice,
    TResult? Function(SetOrder value)? setOrder,
    TResult? Function(ClearOrder value)? clearOrder,
    TResult? Function(EndPhase value)? endPhase,
  }) {
    final _that = this;
    switch (_that) {
      case PlayCard() when playCard != null:
        return playCard(_that);
      case UseSkill() when useSkill != null:
        return useSkill(_that);
      case ResolveChoice() when resolveChoice != null:
        return resolveChoice(_that);
      case SetOrder() when setOrder != null:
        return setOrder(_that);
      case ClearOrder() when clearOrder != null:
        return clearOrder(_that);
      case EndPhase() when endPhase != null:
        return endPhase(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String cardId, String? target)? playCard,
    TResult Function(String officerId, String? target)? useSkill,
    TResult Function(int index)? resolveChoice,
    TResult Function(String officerId, Order order)? setOrder,
    TResult Function(String officerId)? clearOrder,
    TResult Function()? endPhase,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PlayCard() when playCard != null:
        return playCard(_that.cardId, _that.target);
      case UseSkill() when useSkill != null:
        return useSkill(_that.officerId, _that.target);
      case ResolveChoice() when resolveChoice != null:
        return resolveChoice(_that.index);
      case SetOrder() when setOrder != null:
        return setOrder(_that.officerId, _that.order);
      case ClearOrder() when clearOrder != null:
        return clearOrder(_that.officerId);
      case EndPhase() when endPhase != null:
        return endPhase();
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
  TResult when<TResult extends Object?>({
    required TResult Function(String cardId, String? target) playCard,
    required TResult Function(String officerId, String? target) useSkill,
    required TResult Function(int index) resolveChoice,
    required TResult Function(String officerId, Order order) setOrder,
    required TResult Function(String officerId) clearOrder,
    required TResult Function() endPhase,
  }) {
    final _that = this;
    switch (_that) {
      case PlayCard():
        return playCard(_that.cardId, _that.target);
      case UseSkill():
        return useSkill(_that.officerId, _that.target);
      case ResolveChoice():
        return resolveChoice(_that.index);
      case SetOrder():
        return setOrder(_that.officerId, _that.order);
      case ClearOrder():
        return clearOrder(_that.officerId);
      case EndPhase():
        return endPhase();
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String cardId, String? target)? playCard,
    TResult? Function(String officerId, String? target)? useSkill,
    TResult? Function(int index)? resolveChoice,
    TResult? Function(String officerId, Order order)? setOrder,
    TResult? Function(String officerId)? clearOrder,
    TResult? Function()? endPhase,
  }) {
    final _that = this;
    switch (_that) {
      case PlayCard() when playCard != null:
        return playCard(_that.cardId, _that.target);
      case UseSkill() when useSkill != null:
        return useSkill(_that.officerId, _that.target);
      case ResolveChoice() when resolveChoice != null:
        return resolveChoice(_that.index);
      case SetOrder() when setOrder != null:
        return setOrder(_that.officerId, _that.order);
      case ClearOrder() when clearOrder != null:
        return clearOrder(_that.officerId);
      case EndPhase() when endPhase != null:
        return endPhase();
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class PlayCard implements GameAction {
  const PlayCard({required this.cardId, this.target, String? $type})
    : $type = $type ?? 'playCard';
  factory PlayCard.fromJson(Map<String, dynamic> json) =>
      _$PlayCardFromJson(json);

  final String cardId;
  final String? target;

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlayCardCopyWith<PlayCard> get copyWith =>
      _$PlayCardCopyWithImpl<PlayCard>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PlayCardToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlayCard &&
            (identical(other.cardId, cardId) || other.cardId == cardId) &&
            (identical(other.target, target) || other.target == target));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, cardId, target);
  }

  @override
  String toString() {
    return 'GameAction.playCard(cardId: $cardId, target: $target)';
  }
}

/// @nodoc
abstract mixin class $PlayCardCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory $PlayCardCopyWith(PlayCard value, $Res Function(PlayCard) _then) =
      _$PlayCardCopyWithImpl;
  @useResult
  $Res call({String cardId, String? target});
}

/// @nodoc
class _$PlayCardCopyWithImpl<$Res> implements $PlayCardCopyWith<$Res> {
  _$PlayCardCopyWithImpl(this._self, this._then);

  final PlayCard _self;
  final $Res Function(PlayCard) _then;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? cardId = null, Object? target = freezed}) {
    return _then(
      PlayCard(
        cardId: null == cardId
            ? _self.cardId
            : cardId // ignore: cast_nullable_to_non_nullable
                  as String,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class UseSkill implements GameAction {
  const UseSkill({required this.officerId, this.target, String? $type})
    : $type = $type ?? 'useSkill';
  factory UseSkill.fromJson(Map<String, dynamic> json) =>
      _$UseSkillFromJson(json);

  final String officerId;
  final String? target;

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UseSkillCopyWith<UseSkill> get copyWith =>
      _$UseSkillCopyWithImpl<UseSkill>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UseSkillToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UseSkill &&
            (identical(other.officerId, officerId) ||
                other.officerId == officerId) &&
            (identical(other.target, target) || other.target == target));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, officerId, target);
  }

  @override
  String toString() {
    return 'GameAction.useSkill(officerId: $officerId, target: $target)';
  }
}

/// @nodoc
abstract mixin class $UseSkillCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory $UseSkillCopyWith(UseSkill value, $Res Function(UseSkill) _then) =
      _$UseSkillCopyWithImpl;
  @useResult
  $Res call({String officerId, String? target});
}

/// @nodoc
class _$UseSkillCopyWithImpl<$Res> implements $UseSkillCopyWith<$Res> {
  _$UseSkillCopyWithImpl(this._self, this._then);

  final UseSkill _self;
  final $Res Function(UseSkill) _then;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? officerId = null, Object? target = freezed}) {
    return _then(
      UseSkill(
        officerId: null == officerId
            ? _self.officerId
            : officerId // ignore: cast_nullable_to_non_nullable
                  as String,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class ResolveChoice implements GameAction {
  const ResolveChoice({required this.index, String? $type})
    : $type = $type ?? 'resolveChoice';
  factory ResolveChoice.fromJson(Map<String, dynamic> json) =>
      _$ResolveChoiceFromJson(json);

  final int index;

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResolveChoiceCopyWith<ResolveChoice> get copyWith =>
      _$ResolveChoiceCopyWithImpl<ResolveChoice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ResolveChoiceToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResolveChoice &&
            (identical(other.index, index) || other.index == index));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, index);
  }

  @override
  String toString() {
    return 'GameAction.resolveChoice(index: $index)';
  }
}

/// @nodoc
abstract mixin class $ResolveChoiceCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory $ResolveChoiceCopyWith(
    ResolveChoice value,
    $Res Function(ResolveChoice) _then,
  ) = _$ResolveChoiceCopyWithImpl;
  @useResult
  $Res call({int index});
}

/// @nodoc
class _$ResolveChoiceCopyWithImpl<$Res>
    implements $ResolveChoiceCopyWith<$Res> {
  _$ResolveChoiceCopyWithImpl(this._self, this._then);

  final ResolveChoice _self;
  final $Res Function(ResolveChoice) _then;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? index = null}) {
    return _then(
      ResolveChoice(
        index: null == index
            ? _self.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class SetOrder implements GameAction {
  const SetOrder({required this.officerId, required this.order, String? $type})
    : $type = $type ?? 'setOrder';
  factory SetOrder.fromJson(Map<String, dynamic> json) =>
      _$SetOrderFromJson(json);

  final String officerId;
  final Order order;

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SetOrderCopyWith<SetOrder> get copyWith =>
      _$SetOrderCopyWithImpl<SetOrder>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SetOrderToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SetOrder &&
            (identical(other.officerId, officerId) ||
                other.officerId == officerId) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, officerId, order);
  }

  @override
  String toString() {
    return 'GameAction.setOrder(officerId: $officerId, order: $order)';
  }
}

/// @nodoc
abstract mixin class $SetOrderCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory $SetOrderCopyWith(SetOrder value, $Res Function(SetOrder) _then) =
      _$SetOrderCopyWithImpl;
  @useResult
  $Res call({String officerId, Order order});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class _$SetOrderCopyWithImpl<$Res> implements $SetOrderCopyWith<$Res> {
  _$SetOrderCopyWithImpl(this._self, this._then);

  final SetOrder _self;
  final $Res Function(SetOrder) _then;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? officerId = null, Object? order = null}) {
    return _then(
      SetOrder(
        officerId: null == officerId
            ? _self.officerId
            : officerId // ignore: cast_nullable_to_non_nullable
                  as String,
        order: null == order
            ? _self.order
            : order // ignore: cast_nullable_to_non_nullable
                  as Order,
      ),
    );
  }

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_self.order, (value) {
      return _then(_self.copyWith(order: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class ClearOrder implements GameAction {
  const ClearOrder({required this.officerId, String? $type})
    : $type = $type ?? 'clearOrder';
  factory ClearOrder.fromJson(Map<String, dynamic> json) =>
      _$ClearOrderFromJson(json);

  final String officerId;

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ClearOrderCopyWith<ClearOrder> get copyWith =>
      _$ClearOrderCopyWithImpl<ClearOrder>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ClearOrderToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ClearOrder &&
            (identical(other.officerId, officerId) ||
                other.officerId == officerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, officerId);
  }

  @override
  String toString() {
    return 'GameAction.clearOrder(officerId: $officerId)';
  }
}

/// @nodoc
abstract mixin class $ClearOrderCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory $ClearOrderCopyWith(
    ClearOrder value,
    $Res Function(ClearOrder) _then,
  ) = _$ClearOrderCopyWithImpl;
  @useResult
  $Res call({String officerId});
}

/// @nodoc
class _$ClearOrderCopyWithImpl<$Res> implements $ClearOrderCopyWith<$Res> {
  _$ClearOrderCopyWithImpl(this._self, this._then);

  final ClearOrder _self;
  final $Res Function(ClearOrder) _then;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({Object? officerId = null}) {
    return _then(
      ClearOrder(
        officerId: null == officerId
            ? _self.officerId
            : officerId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class EndPhase implements GameAction {
  const EndPhase({String? $type}) : $type = $type ?? 'endPhase';
  factory EndPhase.fromJson(Map<String, dynamic> json) =>
      _$EndPhaseFromJson(json);

  @JsonKey(name: 'type')
  final String $type;

  @override
  Map<String, dynamic> toJson() {
    return _$EndPhaseToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is EndPhase);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GameAction.endPhase()';
  }
}
