import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

interface Student {
  _id:number,
  name:string,
  age:number//属性
}

@Entry
@Component
struct DbPage {
  @State message: string = 'Hello World';
  store:relationalStore.RdbStore | null = null;
  stuList:Student[]=[]//对象类型数组

  build() {
    Column({space:20}){
      //短连接：在一个业务中（函数） 连接=>CRUD =>关闭连接 存在周期最短
      //长连接：APP启动（连接 从来不关闭）=>在一个业务中（函数）CRUD（多次） =>APP退出（关闭连接）
      //连接池（Web开发）
      //一个库对应一个数据库文件（.db）
      //如果库不存在，创建并 连接（返回数据库对象）
      //如果库存在，连接
      Button('创建/连接数据库')
        .width('61.8%')
        .onClick(()=>{
          relationalStore.getRdbStore(getContext(),{
            name:'stu.db',
            securityLevel:relationalStore.SecurityLevel.S1//从1到4 安全性递增
          })
            .then((store)=>{
              this.store=store;
              this.getUIContext().getPromptAction().showToast({message:'创建/连接数据库成功'})
            })
            .catch((err:BusinessError)=>{
              this.getUIContext().getPromptAction().showToast({message:err.message})
            })
        })

      Button('建表')
        .width('61.8%')
        .onClick(()=>{
          let sql = 'create table if not exists student (_id integer primary key autoincrement,name text ,age integer)';
          // ？ 短路效果 如果store为null 后面的函数不会调用 若store不为null 正常调用函数
          //executeSql()：执行建表 增删改
          //querySql()：执行查询
          if(this.store != null){
            this.store?.executeSql(sql)
              .then(() => {
                this.getUIContext().getPromptAction().showToast({ message: '建表成功' })
              })
              .catch((err: BusinessError) => {
                this.getUIContext().getPromptAction().showToast({ message: err.message })
              })
          }else{
            this.getUIContext().getPromptAction().showToast({ message: '未建立数据库连接' })
          }
        })

      //增删查
      //插入数据
      Button('插入数据')
        .width('61.8%')
        .onClick(()=>{
          let sql = 'insert into student(name,age) values(?,?)'; //？表示占位符
          if(this.store!=null){

            this.store?.executeSql(sql, ['张三', 20])//数组对应两个？的值
            //this.store?.insert('student',{name:'李四',age:21})
              .then(() => {
                this.getUIContext().getPromptAction().showToast({ message: '插入成功' })
              })
              .catch((err: BusinessError) => {
                this.getUIContext().getPromptAction().showToast({ message: err.message })
              })
          }else{
            this.getUIContext().getPromptAction().showToast({ message: '未建立数据库连接' })
          }
        })

      //删除数据
      Button('删除数据')
        .width('61.8%')
        .onClick(()=>{
          let sql = 'delete from student';
          if(this.store!=null){
             //不写条件就全清空
            this.store?.executeSql(sql)//没有参数
              .then(() => {
                this.getUIContext().getPromptAction().showToast({ message: '删除成功' })
              })
              .catch((err: BusinessError) => {
                this.getUIContext().getPromptAction().showToast({ message: err.message })
              })
          }else{
            this.getUIContext().getPromptAction().showToast({ message: '未建立数据库连接' })
          }
        })

      //查询数据
      Button('查询数据')
        .width('61.8%')
        .onClick(()=>{
          let sql = 'select * from student';//order by排序
          if(this.store!=null){
            this.store?.querySql(sql)//没有参数
              .then((result) => {//返回结果集result
                //遍历
                while (result.goToNextRow()){//移动到下一行
                  //在log窗口输出
                  console.log(result.getLong(0)+','+result.getString(1)+','+result.getLong(2));
                  //把结果封装成对象，保存到数组中
                  //{属性：值，属性：值}对象
                  this.stuList.push({_id:result.getLong(0),name:result.getString(1),age:result.getLong(2)});
                }
                result.close();//关闭结果集对象
                this.getUIContext().getPromptAction().showToast({ message: '查询成功' })
              })
              .catch((err: BusinessError) => {
                this.getUIContext().getPromptAction().showToast({ message: err.message })
              })
          }else{
            this.getUIContext().getPromptAction().showToast({ message: '未建立数据库连接' })
          }
        })

      //显示数据
      Button('显示stuList')
        .width('61.8%')
        .onClick(()=>{
          //stuList:对象数组
          //测试:JSON.stringify() 把JSON对象转成字符串
          this.getUIContext().getPromptAction().showToast({ message: JSON.stringify(this.stuList) });

          // 把名字取出来显示
          for(let i=0;i<this.stuList.length;i++){
            //this.stuList[i].name //取属性的值
            this.getUIContext().getPromptAction().showToast({ message:this.stuList[i].name});
          }
        })

      Button('关闭连接')
        .width('61.8%')
        .onClick(()=>{
          if(this.store!=null){
            this.store?.close()
              .then(() => {
                this.getUIContext().getPromptAction().showToast({ message: '关闭连接成功' })
                this.store = null;
              })
              .catch((err: BusinessError) => {
                this.getUIContext().getPromptAction().showToast({ message: err.message })
              })
          }else{
            this.getUIContext().getPromptAction().showToast({ message: '未建立数据库连接' })
          }
        })

    }
    .height('100%')
    .width('100%')
  }
}