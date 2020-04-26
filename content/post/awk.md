---
title: "awk命令使用"
description: "awk命令使用"
tags: [ "Liunx基础"]
categories: [ "Liunx" ]
keywords: [ "awk" ]
date: 2017-04-06
lastmod: 2018-12-23
---
### awk 工作模式
`awk`的工作过程是这样的：按行读取输入(标准输入或文件)，对于符合模式`pattern`的行，执行`action`。当`pattern`省略时表示匹配任何字符串；当`action`省略时表示执行`'{print}'`；它们不可以同时省略。每一行输入，对`awk`来说都是一条记录(`record`)，`awk`使用`$0`来引用当前记录

<!-- more -->

> 语法

```shell
awk [options] 'program'' file…
awk [options] -f programfile var=value file…
awk [options] 'BEGIN{ action;… } pattern{ action;… } END{action;… }' file ...
```

### 常用选项

| 选项                  | 描述      |
| :------------------ | :------ |
| -F  field separator | 指定字段分割符 |
| -v var=value        | 赋值变量    |

### 内建变量

| 内建变量                         | 描述                   |
| ---------------------------- | -------------------- |
| FS (field separator)         | 输入字段分隔符(默认为空白)       |
| RS (record separator)        | 输入记录分隔符(默认为换行)       |
| OFS (output field separator) | 输出字段分隔符(默认为空白)       |
| ORS (output record sparator) | 输出字段分割符              |
| NF (number field)            | 字段数量                 |
| NR (number row)              | 行号(已经处理过的) 后面可跟多个文件  |
| FNR (file number row)        | 行号(当前处理文件的) 后面可跟多个文件 |
| ARGV (args value)            | 命令行参数的数组             |
| ARGC(args count)             | 命令行参数(后跟的文件) 个数      |

> 例如 

```shell
[root: ~]# awk 'BEGIN {print ARGC,ARGV[0],ARGV[2]}' /etc/fstab /etc/passwd
3 awk /etc/passwd
```

注意: 输入参数只有两个,但是显示3个,因为awk本身的命令也算一个 `ARGV[0]` 表示命令自身 `ARGV[2]`表示第二个

### 格式化打印

> 语法

```shell
printf "FORMAT", item1, item2, ...
```

- 必须要写FORMAT
- 不会自动换行,要手动加"\n"
- FORMAT中需要分别为后面每个item指定格式符

> 格式符

格式符:必须与 item 一一对应

| 个数符   | 含义              |
| ----- | --------------- |
| %c    | 见一个数最ASCII字符显示  |
| %d,%i | 显示一个整数 %i 是十进制的 |
| %e.%E | 科学记数法显示         |
| %f    | 显示为浮点数          |
| %g,%G | 以科学计数法或浮点形式显示数值 |
| %s    | 显示字符串           |
| %u    | 无符号整数           |
| %%    | 显示%自身           |

> 修饰符

控制显示的位宽,左对齐右对齐等等

| 修饰符   | 含义                           |
| ----- | ---------------------------- |
| #[.#] | 前面#表示位宽,后面表示输出的浮点型数字小数点后面的长度 |
| -     | 左对齐,不写默认为右对其                 |
| +     | 显示数字的正负符号                    |

> 例子

```shell
[root: ~]# awk -F : 'BEGIN{printf "%-10s%-10s%-10s\n","username","uid","shell"}'\
'{printf "%-10s%-10d%-10s\n",$1,$3,$NF}' /etc/passwd
username  uid       shell     
root      0         /bin/bash 
bin       1         /sbin/nologin
daemon    2         /sbin/nologin
...
```

注意: 'BEGIN{action}''{action}' ,中间不能有空格,fomat格式化后面的字段,如果变量不加引号,字符串要加引号

### 操作符

awk程序支持多种匹配模式来过滤数据记录,类似sed地址定界

> 算术操作符

跟其他变成语言类似注意次方的使用和bash的区别 `x^y` `x%y` 

小技巧

`+x` : 可以将某个字段转换成数字

`-x` :转换成负数

> 例如监控磁盘的使用率

```shell
<root: ~># df | awk '{if(+$5>=10)printf"%-20s will full,used %-3s\n",$1,$5}'
/dev/mapper/cl-root  will full,used 22%
/dev/sda1            will full,used 14%
/dev/sdb1            will full,used 20%
```

`$5` 一列有个%号 使用 `+$5` 可以去掉%做数学运算,超过10%,报警

> 赋值操作符

都是如下表示方式 `++` `+=` 等

> 模式匹配

和bash scripts类似使用 `~` `!~` ,判断左边是否和右边匹配

> 匹配行范围

格式 : /part1/,/part2/  表示处理匹配/part1/ 到/part2/ 的之间所有行

注意:awk中不支持  3,8 这中行号的写法,真确的写法应该是 (NR>=3&&NR<=8)

> 例子

```shell
<root: ~># cat -n /etc/passwd | awk -F : '(NR>=3&&NR<=4){print $1,$3}'
     3	daemon 2
     4	adm 3
```

### 流程控制语句

#### 判断语句

if 单分支: if (condition)  {statment1;stament2;...}

注意:如果只有一条命令,可以不用加花括号,否侧一定要加,且用分号隔开

多分支语法: if (condition) statement1;else statement2

> 例如

```shell
<root: ~># netstat -antu | awk '{if($6=="LISTEN"){x++}else{y++}}END{print x,y}'
5 9
```

表示: 处理每行的`$6` 如果为LISTEN 就执行x++, 执行完后执行END后的统计

 条件表达式(三目表达式) selector?if-true-expression1:if-false-expression2 

表示:selector 是否匹配,匹配的话继续匹配expression1否则继续匹配-expression2

> 1 例如

```shell
[root: ~]# awk -F: '$3>500?/\/bin\/bash$/:$3==0 {print $0}' /etc/passwd
root:x:0:0:zhangxingshi,(0516)-5666123,18567087793,12344441113:/root:/bin/bash
zxs:x:501:501::/home/zxs:/bin/bash
zxs1:x:502:502::/home/zxs1:/bin/bash
```

注意:/part/  part中的字符串有`/` 要转义

> 例如


```shell
[root: ~]# awk -F: '{$3>499?usertype="common user":usertype="sysuser";printf "%10s:%-10s\n",$1,usertype}' /etc/passwd
      root:sysuser   
       bin:sysuser   
    daemon:sysuser   
    ...
```

#### 循环语句

> 语法

1 while循环: while(condition){statement;…}

> 例子

```shell
<root: ~># awk '/^[[:space:]]*linux16/{i=1;while(i<=NF){print $i,length($i);i++}}'/etc/grub2.cfg
```

表示: 查找 /etc/grub2.cfg 文件中匹配以空格后跟linux16的行,并统计每个字段的长度 `length()` 内建函数

2 for循环

语法 :  表达式一 :  for(expr1;expr2;expr3) {statement;…}   和c语言类似的语法

> 例如 : 打印斐波那契数列

```shell
[root: ~]# cat fibonacci.awk 
#!/bin/awk -f
BEGIN{
    $1=1
    $2=1
    OFS=","
    for(i=3;i<=10;i++)
    {
        $i=$(i-2)+$(i-1)
    }
    print
}
[root: ~]# ./fibonacci.awk 
1,1,2,3,5,8,13,21,34,55
```

​	    表达式二:  for(var in array) {for-body}   用于遍历数组: 

#### 循环控制

awk本身就是循环遍历,文件的每一行,然后进行处理. awk里的循环,一般循环的是字段

break 和 contine

例子: 计算100 奇数的和

```shell
<root: ~># awk 'BEGIN{sum=0;for(i=1;i<=100;i++){if(i%2==0)continue;sum+=i}print sum}'
2500
```

next  : 表示提前结束本行的处理,对下一行进行循环. 看着和contine 差不多,但是next 跳过的是awk 自身对行的循环,而不是内部字段的循环

例如 

```shell
<root: ~># awk -F : '{if($3%2==0)next;print $1,$3}' /etc/passwd
bin 1
adm 3
...
```

分析: `$3` 为uid 的字段,表示uid为偶数就 `next` 处理下一行, 结果为打印uid为奇数行的 1 3 字段 

### 数组

awk中的数组格式和bash中的关联数组类似,下标通常引用字段的名称,用于统计

- 可使用任意字符串；字符串要使用双引号括起来
- 如果某数组元素事先不存在，在引用时，awk会自动创建此元素，并将其值初始化为“空串”
- 若要判断数组中是否存在某元素，要使用“var in array”格式进行遍历

> 例子1

```shell
[root: ~]# awk -F : '{shell[$NF]++}END{for(i in shell)print i,shell[i]}' /etc/passwd
/sbin/shutdown 1
/bin/bash 17
/sbin/nologin 22
/sbin/halt 1
/bin/sync 1
```

分析 :`shell` 是初始化的数组 `shell[$NF]++` 表示式中 `$NF`式文件中的shell类型,不同的shell 类型不同,数组的下标就不同,相同的下标值就会累加,最后统计

> 例子 2

要求统计测试文件test.txt 中分别男生和女生考试成绩的总成绩 和平均值

```shell
[root: ~]# cat test.txt 
mage 97 male
wang 90 male
zhang 80 female
li  87 female
[root: ~]# awk '{sum[$3]+=$2;num[$3]++}END{for (i in sum) print i,sum[i],sum[i]/num[i] }' test.txt 
female 167 83.5
male 187 93.5
```

分析: 本题初始两个数组 `sum` 和  `num ` 下标都为 `$3` ,(就 male 和 female 两种) ,`sum[$3]`  累加 `$2` 表示同一个下标的总成绩, `num[$3]` 累加1 表示同一个下标出现的此时, 引用数组必须要用 `for (var in array)` 的形式, var 表示数组的下标 .

当然,如果统计某个字段的总类较多,适合用数组的表示方法. 本例中`$3` 字段中有两中,用 `if` 比较简单明了

```shell
[root: ~]# awk '{if($3 == "male"){msum+=$2;mnum++}else{fsum+=$2;fnum++}}END{printf "male: %5-d%.1f\n",msum,msum/mnum;printf "female: %5-d%.1f\n",fsum,fsum/fnum}' test.txt 
male: 187  93.5
female: 167  83.5
```

分析: 逻辑简单,需要四个变量,需要打印两次 ,所以需要 printf 换行,写法较乱

### 内建函数

#### rand()

rand()：返回0和1之间一个随机数,不能直接调用 rand(),输出的值相同,需要使用srand(),并且通过运算获得想要的值的范围

> 例如: 获取10个100以内的随机整数

```shell
[root: ~]# awk 'BEGIN{srand();for(i=1;i<=10;i++)print int(rand()*100)}'
```

#### length()

返回指定字符串的长度

#### sub()

sub函数的参数格式为 `sub(r,s,[t])` 表示:对t字符串进行搜索r表示的模式匹配的内容，并将第一个匹配的内容替换为s

> 例子

```shell
[root: ~]# date +"%F %T"
2017-09-04 10:04:25
[root: ~]# date +"%F %T" | awk 'sub(/:/,"-",$2)'
2017-09-04 10-05:12
```

注意 : `sub()`  默认值替换第一个匹配到的字符,全部替换要用 `gsub()`

#### split()

参数格式为`split(s,array,[r])` 以r为分隔符，切割字符串s，并将切割后的结果保存至array所表示的数组中，第一个索引值为1,第二个索引值为2,…

> 例如

```shell
<root: ~># head -20 <(awk  '{print $5}' f1.log) 
and
Address
172.18.5.67:38848
172.18.5.67:38854
172.18.5.67:38850
```

如上文件`f1.log` 第5个字段是 ip:socket 的方式,要想在将 `$5` 切片成只剩ip 然后统计相同ip出现的次数 可以使用 `split()` 

```shell
<root: ~># awk  'NR>2{split($5,socket,":");ip[socket[1]]++}END{for (i in ip)print i,ip[i]}' f1.log 
 3
0.0.0.0 2
172.18.253.34 2
172.18.5.67 4105
```

分析 :`split()`  切片 `$5 ` 后保存在数组 `socket`  里 `socket[1]` 保存的是ip地址 ,然后再以 `socket[1]` 为下标

累加 `ip[socket[1]]++` ,取出 ip  数组的值和对应的下标就统计出来了

### 小技巧

在模式匹配中一般,关系表达是为真,才会处理,一般表示为,

> 例如

```shell
[root: archive]# awk '!/^UUID/{print $0}' /etc/fstab
[root: archive]# awk '!/^UUID/{print}' /etc/fstab
[root: archive]# awk '!/^UUID/' /etc/fstab
```

注意 : 以上三种表示方法的输出结果都一样, prinf 不加参数默认打印 `$0` ;{action} 不写默认动作为

{print $0} .

> 还可以有一些奇葩方式

```shell
[root: archive]# seq 10 | awk 'i=!i'     #打印奇数行
```

分析 :awk默认初始所有变量为 空或者0, (0表示假,表不不执行默认动作{print $0}) 

```shell
[root: archive]# (seq 10;seq 10) | awk '!line[$0]++'
```

分析: awk读取每行文件 ,`line[$0]` 初始值为0(即为假) `!line[$0]++`, `$0` 表示整行, 只要行不同,就是数组中的一个新的元素,初始值为 0 ,如果出现相同的行 `!line[$0] ` 有值了即为假 ,不打印重复的行

### 练习:

>  统计/etc/init.d/functions 文件下的单词数

```shell
[root: ~]# cat word_count.awk 
#!/bin/awk -f
BEGIN{
	FS="[^a-zA-Z]+"
	printf "%-15s:%-5s\n---------------------\n","Word","Count"
}
{for(i=1;i<=NF;i++)
	{if( $i ~ /./ )
		{word[$i]++
		}
	}
}
END{for(j in word)
		{printf "%-15s:%-5s\n",j,word[j]
		}
}
[root: ~]# ./word_count.awk /etc/init.d/functions 
Word           :Count
---------------------
otherwise      :1    
pidfileofproc  :2    
...
```

> 提取出字符串Yd$C@M05MB%9&Bdh7dq+YVixp3vpw中的所有数字

```shell
[root: ~]# echo "Yd$C@M05MB%9&Bdh7dq+YVixp3vpw" | awk -F "" \
> '{ for (i=1;i<+NF;i++)\
>      { if ($i ~ /[0-9]/) printf $i}\
> '}
```

注意: -F "" 表示以空为分隔符.表示每个字符算一个,字段

> 合并相同列的两个文件

```shell
<root: ~># cat f2.txt 
Number  score
01      97
02      56
03      77
<root: ~># cat f1.txt 
Name  Number  Gendar
zhang    01       M
li       02       F
wang     03       M
<root: ~># awk 'NR==FNR{score[$1]=$2;next}{printf "%30-s%10-s\n",$0,score[$2]}' f2.txt f1.txt 
Name  Number  Gendar          score     
zhang    01       M           97        
li       02       F           56        
wang     03       M           77        
```

分析: 两个文件共同列是,`f2.txt` 中的 `$1` 和 `f1.txt` 中的 `$2 ` , 由于awk 处理两个文件 ,`NR==FNR` 表示的是第一个文件, 目的是将第一个文件的不同列合并到第二个文件里, 处理第一个文件是,不输出信息而是将 `$1` 当作下标 `$2` 当作值存储在 数组 score中, 处理到第二个文件时 直接打印 `$0` 和数组的值,注意下标为 这个文件的`$2`   
