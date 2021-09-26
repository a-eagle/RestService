<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<v-row justify="space-around">
	<v-col cols="10"  md="4">  <v-text-field label="表名（中文）：" v-model.trim = 'newTableInfo.tabName' > </v-text-field>  </v-col>
	<v-col cols="10"  md="4">  <v-text-field label="表名MD5：" v-model = 'newTableInfo.tabNameMD5' readonly> </v-text-field>  </v-col>
	<v-col cols="2"  md="1"> <v-btn block @click="newTableToServer" > 创建表  </v-btn>  </v-col>
</v-row>

<v-alert v-model="newTableInfo.showAlert" border="left" close-text="Close Alert" color="green" elevation = 4 text :type = "newTableInfo.alertType"  dismissible >
	{{newTableInfo.alertText}}
</v-alert>

<v-row justify="space-around">
	<v-col > 列名（中文）  </v-col>
	<v-col > 列名(英文)  </v-col>
	<v-col > 数据类型 </v-col>
	<v-col > 最大长度 </v-col>
	<v-col cols="2"  md="1">  </v-col>
</v-row>

<v-row justify="space-around" v-for = 'c in newTableInfo.alreadyCreateColumns' :key = "c._name" >
	<v-col > {{c._name_cn}}  </v-col>
	<v-col > {{c._name}}  </v-col>
	<v-col > {{c._data_type}}  </v-col>
	<v-col > {{c._max_len}}  </v-col>
	<v-col cols="2"  md="1">  </v-col>
</v-row>


<v-row justify="space-around">
	<v-col > <v-text-field v-model.trim = 'newTableInfo.add._name_cn' >  </v-col>
	<v-col > <v-text-field  v-model.trim = 'newTableInfo.add._name' > </v-col>
	<v-col > <v-text-field   v-model.trim = 'newTableInfo.add._data_type' > </v-col>
	<v-col > <v-text-field   v-model.trim = 'newTableInfo.add._max_len' > </v-col>
	<v-col cols="2"  md="1" @click="newColumnToServer">  <v-btn block> 创建列  </v-btn> </v-col>
</v-row>


