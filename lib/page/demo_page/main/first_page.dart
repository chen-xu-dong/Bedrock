


import 'package:flutter/material.dart';
import 'package:flutter_bedrock/base_framework/config/router_manager.dart';
import 'package:flutter_bedrock/base_framework/ui/widget/provider_widget.dart';
import 'package:flutter_bedrock/base_framework/utils/refresh_helper.dart';
import 'package:flutter_bedrock/base_framework/utils/show_image_util.dart';
import 'package:flutter_bedrock/base_framework/view_model/app_model/app_cache_model.dart';
import 'package:flutter_bedrock/base_framework/view_model/app_model/user_view_model.dart';
import 'package:flutter_bedrock/base_framework/widget_state/base_state.dart';
import 'package:flutter_bedrock/page/demo_page/main/first/view_model/first_view_model.dart';
import 'package:flutter_bedrock/page/demo_page/main/first/widget/first_banner.dart';
import 'package:flutter_bedrock/page/demo_page/main/first/widget/first_skeleton_page.dart';
import 'package:flutter_bedrock/page/demo_page/main_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'first/entity/first_card_entity.dart';

class FirstPage extends StatefulWidget {

  final TransportScrollController transportScrollController;


  FirstPage(this.transportScrollController);

  @override
  State<StatefulWidget> createState() {
    return FirstPageState();
  }

}

class FirstPageState extends BaseState<FirstPage> with AutomaticKeepAliveClientMixin {

  ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    widget.transportScrollController(scrollController);
    super.initState();
  }


  UserViewModel userViewModel;
  FirstViewModel firstViewModel;

  @override
  Widget build(BuildContext context) {

    return switchStatusBar2Dark(
        child: Consumer2<UserViewModel,AppCacheModel>(
      builder: (ctx,userViewModel,cacheModel,child){
        this.userViewModel = userViewModel;
        return ProviderWidget<FirstViewModel>(
          model: FirstViewModel(),
          onModelReady: (model){
            model.initData();
          },
          builder: (ctx,firstModel,child){
            if(firstModel.busy){
              ///骨架屏
              return FirstSkeletonPage();
            }

            firstViewModel = firstModel;
            ///我顶层定义的有 refresh的属性，可以用这个方法获得，并不一定非要这么写
            return RefreshConfiguration.copyAncestor(context: context,
                child: Container(
                  color: Colors.white,
                  width: getWidthPx(750),
                  height: getHeightPx(1236),
                  ///如果不想要flutter 自带的水印，可以用这个包裹  eg:listview \  scrollview
                  child: getNoInkWellListView(scrollView: SmartRefresher(
                    controller:  firstModel.refreshController,
                    header: HomeRefreshHeader(Colors.black),
                    footer: RefresherFooter(),
                    onRefresh: firstModel.refresh,
                    onLoading: firstModel.loadMore,
                    enablePullDown: true,
                    enablePullUp: true,
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: <Widget>[
                        ///slivers 内部的子widget 请务必用SliverToBoxAdapter包裹，或者直接使用sliver**widget
                        SliverToBoxAdapter(
                          child: getSizeBox(height: getWidthPx(98),width: getWidthPx(750)),
                        ),
                        ///banner
                        SliverToBoxAdapter(
                          child: buildBanner(),
                        ),
                        ///transform zone
                        SliverToBoxAdapter(
                          child: buildTransform(),
                        ),

                        SliverToBoxAdapter(
                          child: Container(
                            alignment: Alignment.center,
                            width: getWidthPx(750),
                            color: Color.fromRGBO(240, 240, 240, 1),
                          child: Text("Tip ：点击第一个底部导航键可以滚动到顶部"),),
                        ),

                        ///listview
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (ctx,index){
                                return buildItem(index,firstModel.cardList[index]);
                              },childCount: firstModel.cardList?.length ?? 0
                          ),
                        ),

                      ],
                    ),
                  )),
                ));
          },
        );
      },
    ));
  }

  Widget buildTransform(){
    return Container(
      width: getWidthPx(670),
      height: getHeightPx(100),
      margin: EdgeInsets.symmetric(horizontal: getWidthPx(40),vertical: getWidthPx(40)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildOval("FFloat",Colors.lightBlue),
          buildOval("Cache",Colors.red),
          buildOval("Play",Colors.deepOrange),
          buildOval("Video",Colors.lightBlue),
        ],
      ),
    );
  }

  Widget buildOval(String str,Color color){
    return GestureDetector(
      onTap: (){
        if(str.contains('FFloat')){
          Navigator.of(context).pushNamed(RouteName.ffloat_page);
        }else if(str.contains('Cache')){
          Navigator.of(context).pushNamed(RouteName.cache_data_page);
        }else{
          showToast('施工中...');
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: getWidthPx(100),height: getWidthPx(100),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: Colors.grey[400],spreadRadius: 1.0,offset: Offset(0.8, 0.8),)
          ],
        ),
        child: Text(str,style: TextStyle(color: Colors.white,fontSize: getSp(28)),),
      ),
    );
  }

  Widget buildItem(int index,FirstCardEntity entity){
    return Container(
      color: Color.fromRGBO(248, 248, 248, 1),
      margin: EdgeInsets.only(top: getWidthPx(28), left: getWidthPx(40), right: getWidthPx(40)),
      padding: EdgeInsets.all(10),
      width: getWidthPx(670),
      height: getWidthPx(410),
      child: Column(
        children: <Widget>[
          ShowImageUtil.showImageWithDefaultError(entity.img, getWidthPx(650), getWidthPx(300),
              borderRadius: getHeightPx(16)),
          getSizeBox(height: getWidthPx(30)),
          Text(entity.title,style: TextStyle(color: Colors.black,fontSize: getSp(32)),),
        ],
      ),
    );
  }


  Widget buildBanner(){
    return Container(
      width: getWidthPx(622),
      height: getWidthPx(292),
      child: FirstBanner(
        borderRadius: BorderRadius.circular(getHeightPx(6)),
        imageList: firstViewModel.firstEntity.banner,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}




















