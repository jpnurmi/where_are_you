// Mocks generated by Mockito 5.0.16 from annotations
// in where_are_you/test/where_are_you_model_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:where_are_you/geo_location.dart' as _i4;
import 'package:where_are_you/geo_service.dart' as _i2;
import 'package:where_are_you/geo_source.dart' as _i5;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [GeoService].
///
/// See the documentation for Mockito's code generation for more information.
class MockGeoService extends _i1.Mock implements _i2.GeoService {
  MockGeoService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i4.GeoLocation?> init() =>
      (super.noSuchMethod(Invocation.method(#init, []),
              returnValue: Future<_i4.GeoLocation?>.value())
          as _i3.Future<_i4.GeoLocation?>);
  @override
  void addSource(_i5.GeoSource? source) =>
      super.noSuchMethod(Invocation.method(#addSource, [source]),
          returnValueForMissingStub: null);
  @override
  void removeSource(_i5.GeoSource? source) =>
      super.noSuchMethod(Invocation.method(#removeSource, [source]),
          returnValueForMissingStub: null);
  @override
  _i3.Future<Iterable<_i4.GeoLocation>> search(String? name) =>
      (super.noSuchMethod(Invocation.method(#search, [name]),
              returnValue:
                  Future<Iterable<_i4.GeoLocation>>.value(<_i4.GeoLocation>[]))
          as _i3.Future<Iterable<_i4.GeoLocation>>);
  @override
  String toString() => super.toString();
}
