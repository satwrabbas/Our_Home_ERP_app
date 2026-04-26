//lib\contracts\view\contracts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/contracts_cubit.dart';
import '../../../buildings/cubit/buildings_cubit.dart';
import '../../../settings/cubit/settings_cubit.dart';
import 'add_contract_page.dart';
import 'deleted_contracts_page.dart';
import 'widgets/contracts_search_bar.dart';
import 'widgets/contracts_data_table.dart';
import 'widgets/empty_contracts_view.dart';

// ✨ الأسطر الناقصة التي تسببت في الخطأ (تأكد من صحة المسار حسب مشروعك) ✨
import 'widgets/contracts_search_bar.dart'; 
import 'widgets/contracts_data_table.dart';
import 'widgets/empty_contracts_view.dart';

class ContractsPage extends StatelessWidget {
  const ContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContractsView();
  }
}

class ContractsView extends StatefulWidget {
  const ContractsView({super.key});

  @override
  State<ContractsView> createState() => _ContractsViewState();
}

class _ContractsViewState extends State<ContractsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFAB(context),
      body: BlocConsumer<ContractsCubit, ContractsState>(
        listener: (context, state) {
          if (state.status == ContractsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'خطأ'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ContractsStatus.loading && state.contracts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.clients.isEmpty) {
            return const EmptyContractsView(
              message: 'يرجى إضافة عميل أولاً من قسم العملاء.',
              icon: Icons.group_add,
              iconColor: Colors.grey,
            );
          }
          if (state.contracts.isEmpty) {
            return const EmptyContractsView(
              message: 'لم يتم توقيع أي عقود بعد.',
              icon: Icons.real_estate_agent,
              iconColor: Colors.teal,
            );
          }

          final filteredContracts = state.contracts.where((contract) {
            final client = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first);
            final searchLower = _searchQuery.toLowerCase();
            return client.name.toLowerCase().contains(searchLower) ||
                   contract.apartmentDetails.toLowerCase().contains(searchLower) ||
                   contract.id.contains(searchLower);
          }).toList();

          return Column(
            children: [
              ContractsSearchBar(
                searchQuery: _searchQuery,
                resultCount: filteredContracts.length,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              Expanded(
                child: filteredContracts.isEmpty
                    ? const EmptyContractsView(message: 'لا توجد نتائج للبحث', icon: Icons.search_off, iconColor: Colors.grey)
                    : ListView(children: [ContractsDataTable(contracts: filteredContracts, clients: state.clients)]),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('إدارة العقود والشقق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.teal.shade600,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep, color: Colors.white),
          onPressed: () {
            context.read<ContractsCubit>().fetchDeletedContracts();
            Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<ContractsCubit>(), child: const DeletedContractsPage())));
          },
        ),
      ],
    );
  }

  FloatingActionButton _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<ContractsCubit>()),
              BlocProvider.value(value: context.read<BuildingsCubit>()),
              BlocProvider.value(value: context.read<SettingsCubit>()),
            ],
            child: const AddContractPage(),
          ),
        ),
      ),
      icon: const Icon(Icons.add_home_work),
      label: const Text('عقد جديد'),
      backgroundColor: Colors.teal.shade600,
    );
  }
}