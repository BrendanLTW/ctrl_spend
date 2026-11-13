// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  /// Overridden in `main.dart` with the Drift implementation, so screens
  /// never import `data/`.
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'b2f78f2bec4caaf583a24e1d915dcc092bb7781c';

/// Categories, live, with [CategoryRepository.watch]'s filters.

@ProviderFor(categories)
final categoriesProvider = CategoriesFamily._();

/// Categories, live, with [CategoryRepository.watch]'s filters.

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  /// Categories, live, with [CategoryRepository.watch]'s filters.
  CategoriesProvider._({
    required CategoriesFamily super.from,
    required ({TransactionType? type, bool? archived}) super.argument,
  }) : super(
         retry: null,
         name: r'categoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @override
  String toString() {
    return r'categoriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    final argument = this.argument as ({TransactionType? type, bool? archived});
    return categories(ref, type: argument.type, archived: argument.archived);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesHash() => r'e2f622b2fae97cc8ce555b6b53485d9af9418392';

/// Categories, live, with [CategoryRepository.watch]'s filters.

final class CategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Category>>,
          ({TransactionType? type, bool? archived})
        > {
  CategoriesFamily._()
    : super(
        retry: null,
        name: r'categoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Categories, live, with [CategoryRepository.watch]'s filters.

  CategoriesProvider call({TransactionType? type, bool? archived}) =>
      CategoriesProvider._(
        argument: (type: type, archived: archived),
        from: this,
      );

  @override
  String toString() => r'categoriesProvider';
}
