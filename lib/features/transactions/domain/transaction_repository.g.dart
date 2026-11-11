// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  /// Overridden in `main.dart` with the Drift implementation, so screens
  /// never import `data/`.
  TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'b2b1825eb26f66bc469e05542824dc9ad283ef26';

/// Transactions, live, with [TransactionRepository.watch]'s filters.

@ProviderFor(transactions)
final transactionsProvider = TransactionsFamily._();

/// Transactions, live, with [TransactionRepository.watch]'s filters.

final class TransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          Stream<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $StreamProvider<List<Transaction>> {
  /// Transactions, live, with [TransactionRepository.watch]'s filters.
  TransactionsProvider._({
    required TransactionsFamily super.from,
    required ({
      Period? period,
      TransactionType? type,
      int? categoryId,
      String? search,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'transactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @override
  String toString() {
    return r'transactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Transaction>> create(Ref ref) {
    final argument =
        this.argument
            as ({
              Period? period,
              TransactionType? type,
              int? categoryId,
              String? search,
            });
    return transactions(
      ref,
      period: argument.period,
      type: argument.type,
      categoryId: argument.categoryId,
      search: argument.search,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionsHash() => r'a60fb06a5256b2946a879f1ddf878ce732ad86bf';

/// Transactions, live, with [TransactionRepository.watch]'s filters.

final class TransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Transaction>>,
          ({
            Period? period,
            TransactionType? type,
            int? categoryId,
            String? search,
          })
        > {
  TransactionsFamily._()
    : super(
        retry: null,
        name: r'transactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Transactions, live, with [TransactionRepository.watch]'s filters.

  TransactionsProvider call({
    Period? period,
    TransactionType? type,
    int? categoryId,
    String? search,
  }) => TransactionsProvider._(
    argument: (
      period: period,
      type: type,
      categoryId: categoryId,
      search: search,
    ),
    from: this,
  );

  @override
  String toString() => r'transactionsProvider';
}
