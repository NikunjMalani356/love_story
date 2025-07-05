import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_helper.dart';
import 'package:love_story_unicorn/app/utills/app_function.dart';
import 'package:love_story_unicorn/app/utills/dimension.dart';
import 'package:love_story_unicorn/app/widgets/app_background.dart';
import 'package:love_story_unicorn/app/widgets/app_button.dart';
import 'package:love_story_unicorn/app/widgets/app_image_assets.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/controller/match_making_controller.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/match_making_helper.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class MatchMakingScreen extends StatefulWidget {
  const MatchMakingScreen({super.key});

  @override
  State<MatchMakingScreen> createState() => MatchMakingScreenState();
}

class MatchMakingScreenState extends State<MatchMakingScreen> {
  MatchMakingScreenHelper? matchMakingScreenHelper;
  MatchMakingController? matchMakingController;

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    matchMakingScreenHelper ??= MatchMakingScreenHelper(this);
    return GetBuilder(
      init: MatchMakingController(),
      builder: (MatchMakingController controller) {
        matchMakingController = controller;
        return Scaffold(
          backgroundColor: AppColorConstant.appTransparent,
          body: AppBackground(
            onTapShowBack: () => AppFunction.showComingSoonDialog(info: matchMakingScreenHelper?.infoList),
            backIcon: AppAsset.icInfo,
            showSuffixIcon: true,
            onSuffixTap: () => RouteHelper.instance.gotoFilter(),
            titleText: StringConstant.match,
            titleColor: AppColorConstant.appWhite,
            suffixIcon: AppAsset.icSort,
            isLoading: matchMakingScreenHelper?.isLoading ?? true,
            child: matchMakingScreenHelper?.isLoading == true ? const SizedBox() : buildMatchesView(),
          ),
        );
      },
    );
  }

  Widget buildMatchesView() {
    return Padding(
      padding: const EdgeInsets.only(
        left: DimensPadding.paddingExtraSemiLarge,
        right: DimensPadding.paddingExtraSemiLarge,
        top: DimensPadding.paddingFromBackArrow,
      ),
      child: (matchMakingScreenHelper?.allUsers?.isEmpty ?? true) ? buildNoMatchView() : buildMatchesList(),
    );
  }

  Widget buildNoMatchView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImageAsset(
            image: AppAsset.signUpUnicorn,
            width: MediaQuery.of(context).size.width * 0.5,
          ),
          const AppText(
            StringConstant.noMoreUsersMessage,
            fontSize: Dimens.size22,
            color: AppColorConstant.appWhite,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimens.heightExtraNormal),
          AppButton(
            title: 'preferences!',
            onTap: () => RouteHelper.instance.gotoMandatory(),
          ),
        ],
      ),
    );
  }

  Widget buildMatchesList() => RefreshIndicator(onRefresh: () => matchMakingScreenHelper!.refreshMatches(), child: buildMatchList());

  Widget buildMatchList() {
    return CustomScrollView(
      controller: matchMakingScreenHelper?.scrollController,
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: matchMakingScreenHelper?.aspectRatio ?? (100 / 150),
            crossAxisSpacing: DimensPadding.paddingExtraLargeMedium,
            mainAxisSpacing: DimensPadding.paddingExtraLargeMedium,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final user = matchMakingScreenHelper?.allUsers?[index];
              final isFollowingCurrentUser = matchMakingScreenHelper?.usersFollowingCurrentUser == user;
              return buildMatchCard(index, user: user, isFollowingCurrentUser: isFollowingCurrentUser);
            },
            childCount: matchMakingScreenHelper?.allUsers?.length ?? 0,
          ),
        ),
        if (matchMakingScreenHelper?.isPageLoading ?? false)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColorConstant.appWhite),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildDivider(String title) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingSmallMedium),
          child: AppText(
            title,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget buildMatchCard(int index, {UserModel? user, bool? isFollowingCurrentUser}) {
    return GestureDetector(
      onTap: !matchMakingScreenHelper!.isFollowedAndTimerRunning(user) && matchMakingScreenHelper!.followingWithin48Hours() ||
              matchMakingScreenHelper?.currentUserData!.followers.isNotEmpty == true &&
                  user?.userId != matchMakingScreenHelper?.currentUserData!.followers.first.userId &&
                  matchMakingScreenHelper!.followersWithin48Hours() &&
                  !matchMakingScreenHelper!.isFollowersAndTimerRunning(user) ||
              matchMakingScreenHelper!.isCurrentMutuallyFollowing
          ? null
          : () => matchMakingScreenHelper?.onOpenProfile(user: user),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
            child: AppImageAsset(
              image: user?.headShotImage ?? AppAsset.thirdOnbording,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          if (!matchMakingScreenHelper!.isFollowedAndTimerRunning(user) && matchMakingScreenHelper!.followingWithin48Hours() ||
              matchMakingScreenHelper?.currentUserData!.followers.isNotEmpty == true &&
                  user?.userId != matchMakingScreenHelper?.currentUserData!.followers.first.userId &&
                  matchMakingScreenHelper!.followersWithin48Hours() &&
                  !matchMakingScreenHelper!.isFollowersAndTimerRunning(user) ||
              matchMakingScreenHelper!.isCurrentMutuallyFollowing) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.borderRadiusMedium),
                color: AppColorConstant.appWhite.withOpacity(0.8),
              ),
            ),
            // if (matchMakingScreenHelper?.isCurrentMutuallyFollowing == false)
            // Positioned(
            //   right: 8.0,
            //   top: 8.0,
            //   child: (matchMakingScreenHelper?.currentUserData!.following.isNotEmpty == true)
            //       ? buildTimer(
            //           matchMakingScreenHelper!.currentUserData!.following.firstWhere(
            //             (follow) {
            //               final now = DateTime.now();
            //               final difference = now.difference(follow.followedTime).inHours;
            //               return difference <= matchMakingScreenHelper!.hours;
            //             },
            //           ),
            //         )
            //       : buildTimer(
            //           matchMakingScreenHelper!.currentUserData!.followers.firstWhere(
            //             (follow) {
            //               final now = DateTime.now();
            //               final difference = now.difference(follow.followedTime).inHours;
            //               return difference <= matchMakingScreenHelper!.hours;
            //             },
            //           ),
            //         ),
            // ),
          ],
          Positioned(
            top: 8.0,
            right: 8.0,
            child: Column(
              children: [
                ...?(matchMakingScreenHelper?.currentUserData?.following.where((follow) {
                  final now = DateTime.now().toUtc();
                  final difference = now.difference(follow.followedTime).inSeconds;
                  return follow.userId == user?.userId && difference <= matchMakingScreenHelper!.hours;
                }).map((followModel) => buildTimer(followModel))),
                ...?(matchMakingScreenHelper?.currentUserData?.followers.where((follow) {
                  final now = DateTime.now().toUtc();
                  final difference = now.difference(follow.followedTime).inSeconds;
                  return follow.userId == user?.userId && difference <= matchMakingScreenHelper!.hours;
                }).map((followModel) => buildTimer(followModel))),
              ],
            ),
          ),
          if (matchMakingScreenHelper!.isFollowersAndTimerRunning(user))
            StreamBuilder<Map<String, int>>(
              stream: matchMakingScreenHelper?.followedTimeStream(
                matchMakingScreenHelper?.currentUserData?.followers.first ?? FollowingModel(userId: '', followedTime: DateTime.now().toUtc()),
              ),
              builder: (context, snapshot) {
                final timeRemaining = snapshot.data ?? {'hours': 0, 'minutes': 0, 'seconds': 0};
                final hours = timeRemaining['hours'] ?? 0;
                final minutes = timeRemaining['minutes'] ?? 0;
                final seconds = timeRemaining['seconds'] ?? 0;
                if (hours > 0 || minutes > 0 || seconds > 0) {
                  return Positioned(
                    bottom: 0,
                    child: Lottie.asset(
                      AppAsset.favoriteLottie,
                      width: 100,
                      height: 100,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
        ],
      ),
    );
  }

  Widget buildTimer(FollowingModel followModel) {
    return StreamBuilder<Map<String, int>>(
      stream: matchMakingScreenHelper!.followedTimeStream(followModel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        final timeRemaining = snapshot.data ?? {'hours': 0, 'minutes': 0, 'seconds': 0};
        final hours = timeRemaining['hours'] ?? 0;
        final minutes = timeRemaining['minutes'] ?? 0;
        final seconds = timeRemaining['seconds'] ?? 0;
        if (hours > 0 || minutes > 0 || seconds > 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: AppColorConstant.appBlack,
            child: Text(
              '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
