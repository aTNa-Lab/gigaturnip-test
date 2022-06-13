import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigaturnip/src/features/app/app.dart';
import 'package:gigaturnip/src/features/campaigns/campaigns.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: CampaignsPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        actions: <Widget>[
          IconButton(
            key: const Key('homePage_logout_iconButton'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.read<AppBloc>().add(AppLogoutRequested()),
          )
        ],
      ),
      body: BlocProvider<CampaignsCubit>(
        create: (context) => CampaignsCubit(
          gigaTurnipRepository: context.read<GigaTurnipRepository>(),
          authenticationRepository: context.read<AuthenticationRepository>(),
        ),
        child: const CampaignsView(),
      ),
    );
  }
}