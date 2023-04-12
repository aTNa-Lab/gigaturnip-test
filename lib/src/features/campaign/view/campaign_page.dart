import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gigaturnip/extensions/buildcontext/loc.dart';
import 'package:gigaturnip/src/bloc/bloc.dart';
import 'package:gigaturnip/src/features/campaign/widgets/appbar/tab_bar.dart';
import 'package:gigaturnip/src/theme/index.dart';
import 'package:gigaturnip/src/widgets/drawer/app_drawer.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';
import 'package:gigaturnip_api/gigaturnip_api.dart' as api;

import '../bloc/campaign_cubit.dart';
import 'available_campaign_view.dart';
import 'user_campaign_view.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({Key? key}) : super(key: key);

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  bool showTabs = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SelectableCampaignCubit>(
          create: (context) => CampaignCubit(
            SelectableCampaignRepository(
              gigaTurnipApiClient: context.read<api.GigaTurnipApiClient>(),
            ),
          )..initialize(),
        ),
        BlocProvider<UserCampaignCubit>(
          create: (context) => CampaignCubit(
            UserCampaignRepository(
              gigaTurnipApiClient: context.read<api.GigaTurnipApiClient>(),
            ),
          )..initialize(),
        ),
      ],
      child: BlocListener<SelectableCampaignCubit, RemoteDataState<Campaign>>(
        listener: (context, state) {
          if (state is RemoteDataLoaded<Campaign>) {
            setState(() {
              showTabs = state.data.isNotEmpty;
            });
          }
        },
        child: DefaultTabController(
          length: 2,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: theme.background,
              drawer: const AppDrawer(),
              appBar: AppBar(
                elevation: 0,
                titleSpacing: 0,
                iconTheme: IconThemeData(color: theme.isLight ? theme.neutral30 : theme.neutral90),
                backgroundColor: theme.surface,
                title: Text(
                  context.loc.campaigns,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.sp,
                    color: theme.isLight ? theme.neutral30 : theme.neutral90,
                  ),
                ),
                actions: [
                  // TODO: Replace icons
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
                ],
                // flexibleSpace: Padding(
                //   padding: EdgeInsets.all(12.h),
                //   child: SizedBox(
                //     height: 110.h,
                //     child: Column(
                //       children: [
                //         // SearchBar(),
                //         SizedBox(height: 15.h),
                //         TagBar(),
                //       ],
                //     ),
                //   ),
                // ),
                bottom: CampaignTabBar(
                  hidden: !showTabs,
                  size: const Size.fromHeight(45),
                  tabs: [
                    Tab(text: context.loc.available_campaigns),
                    Tab(text: context.loc.campaigns),
                  ],
                ),
              ),
              body: showTabs
                  ? const TabBarView(
                      children: [
                        AvailableCampaignView(),
                        UserCampaignView(),
                      ],
                    )
                  : const UserCampaignView(),
            ),
          ),
        ),
      ),
    );
  }
}