import 'package:WHOFlutter/api/user_preferences.dart';
import 'package:WHOFlutter/components/page_button.dart';
import 'package:WHOFlutter/api/question_data.dart';
import 'package:WHOFlutter/components/page_scaffold.dart';
import 'package:WHOFlutter/main.dart';
import 'package:WHOFlutter/pages/about_page.dart';
import 'package:WHOFlutter/pages/news_feed.dart';
import 'package:WHOFlutter/pages/onboarding/onboarding_page.dart';
import 'package:WHOFlutter/pages/question_index.dart';
import 'package:WHOFlutter/generated/l10n.dart';
import 'package:WHOFlutter/pages/protect_yourself.dart';
import 'package:WHOFlutter/pages/settings_page.dart';
import 'package:WHOFlutter/pages/travel_advice.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final FirebaseAnalytics analytics;

  HomePage(this.analytics);
  @override
  _HomePageState createState() => _HomePageState(analytics);
}

class _HomePageState extends State<HomePage> {
  final FirebaseAnalytics analytics;
  _HomePageState(this.analytics);

  final String versionString = packageInfo != null
      ? 'Version ${packageInfo.version} (${packageInfo.buildNumber})\n'
      : null;
  final String copyrightString = '© 2020 WHO';
  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  void _initStateAsync() async {
    await _pushOnboardingIfNeeded();
  }

  _launchStatsDashboard() async {
    var url = S.of(context).homePagePageButtonLatestNumbersUrl;
    if (await canLaunch(url)) {
      _logAnalyticsEvent('LatestNumbers');
      await launch(url);
    }
  }

  _logAnalyticsEvent(String name) async {
    await analytics.logEvent(name: name);
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(context,
        title: S.of(context).homePagePageTitle,
        subtitle: S.of(context).homePagePageSubTitle,
        showBackButton: false,
        body: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverStaggeredGrid.count(
              crossAxisCount: 2,
              staggeredTiles: [
                StaggeredTile.count(1, 2),
                StaggeredTile.count(1, 1),
                StaggeredTile.count(1, 1),
                StaggeredTile.count(2, 1),
                StaggeredTile.count(1, 1),
                StaggeredTile.count(1, 1),
              ],
              children: [
                PageButton(
                  Color(0xff008DC9),
                  S.of(context).homePagePageButtonProtectYourself,
                  () {
                    _logAnalyticsEvent('ProtectYourself');
                    return Navigator.of(context).push(
                        MaterialPageRoute(builder: (c) => ProtectYourself()));
                  },
                ),
                PageButton(
                  Color(0xff1A458E),
                  S.of(context).homePagePageButtonLatestNumbers,
                  _launchStatsDashboard,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
                PageButton(
                  Color(0xff3DA7D4),
                  S.of(context).homePagePageButtonYourQuestionsAnswered,
                  () {
                    _logAnalyticsEvent('QuestionsAnswered');
                    return Navigator.of(context).push(MaterialPageRoute(
                        builder: (c) => QuestionIndexPage(
                              dataSource: QuestionData.yourQuestionsAnswered,
                              title: S.of(context).homePagePageButtonQuestions,
                            )));
                  },
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
                PageButton(
                  Color(0xff234689),
                  S.of(context).homePagePageButtonWHOMythBusters,
                  () {
                    _logAnalyticsEvent('MythBusters');
                    return Navigator.of(context).push(MaterialPageRoute(
                        builder: (c) => QuestionIndexPage(
                              dataSource: QuestionData.whoMythbusters,
                              title: S
                                  .of(context)
                                  .homePagePageButtonWHOMythBusters,
                            )));
                  },
                  description:
                      S.of(context).homePagePageButtonWHOMythBustersDescription,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                PageButton(
                  Color(0xff3DA7D4),
                  S.of(context).homePagePageButtonTravelAdvice,
                  () {
                    _logAnalyticsEvent('TravelAdvice');
                    return Navigator.of(context).push(
                        MaterialPageRoute(builder: (c) => TravelAdvice()));
                  },
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                PageButton(
                  Color(0xff008DC9),
                  S.of(context).homePagePageButtonNewsAndPress,
                  () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (c) => NewsFeed())),
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ],
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38.0),
                child: Text(
                  S.of(context).homePagePageSliverListSupport,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffCA6B35)),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(15),
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      padding:
                          EdgeInsets.symmetric(vertical: 24, horizontal: 23),
                      color: Color(0xffCA6B35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(S.of(context).homePagePageSliverListDonate),
                          Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                      onPressed: () {
                        _logAnalyticsEvent('Donate');
                        launch(S.of(context).homePagePageSliverListDonateUrl);
                      })),
              ListTile(
                leading: Icon(Icons.share),
                title: Text(S.of(context).homePagePageSliverListShareTheApp),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  analytics.logShare(
                      contentType: 'App', itemId: null, method: 'Website link');
                  Share.share(
                      S.of(context).commonWhoAppShareIconButtonDescription);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(S.of(context).homePagePageSliverListSettings),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (c) => SettingsPage())),
              ),
              ListTile(
                title: Text(S.of(context).homePagePageSliverListAboutTheApp),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _logAnalyticsEvent('About');
                  return Navigator.of(context)
                    .push(MaterialPageRoute(builder: (c) => AboutPage()));
                },
              ),
              Container(
                height: 25,
              ),
              Text(
                '${versionString ?? ''}$copyrightString',
                style: TextStyle(color: Color(0xff26354E)),
                textAlign: TextAlign.center,
              ),
              Container(
                height: 40,
              ),
            ]),
          )
        ]);
  }

  Future _pushOnboardingIfNeeded() async {
    var onboardingComplete = await UserPreferences().getOnboardingCompleted();

    // TODO: Uncomment for testing.  Remove when appropriate.
    // onboardingComplete = false;

    if (!onboardingComplete) {
      await Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: true, builder: (c) => OnboardingPage()));

      await UserPreferences().setAnalyticsEnabled(true);
      await UserPreferences().setOnboardingCompleted(true);
    }
  }
}
