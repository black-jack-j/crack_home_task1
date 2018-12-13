/*
==================ATTENTION====================

Выполнение ДЗ (сами select'ы) начинается со строки 257

*/
create sequence id_gen_seq minvalue 0 start with 0 increment by 1;

create table object_types (
	object_type_id number default id_gen_seq.nextval primary key,
	parent_id number(20) null,
	name varchar(20) not null,
	description varchar(255) null,
	properties varchar(255) null
);


alter table object_types
	add constraint object_types_parent_id_fk
		foreign key (parent_id)
			references object_types(object_type_id)
				on delete cascade;

create table objects (
	object_id number default id_gen_seq.nextval primary key,
	parent_id  number null,
	object_type_id number not null,
	name varchar(20) not null,
	description varchar(255) null,
	order_number number null,
	foreign key (object_type_id)
		references object_types(object_type_id)
			on delete cascade
);


alter table objects
	add constraint objects_parent_id_fk
		foreign key (parent_id)
			references objects(object_id)
				on delete cascade;


create table attr_types (
	attr_type_id number default id_gen_seq.nextval primary key,
	name varchar(20) not null,
	properties varchar(255) not null
);


create table attr_groups (
	attr_group_id number default id_gen_seq.nextval primary key,
	name varchar(20) not null,
	properties varchar(255) not null
);


create table attributes (
	attr_id number default id_gen_seq.nextval primary key,
	attr_type_id number not null,
	attr_group_id number not null,
	name varchar(20) not null,
	description varchar(255) null,
	ismultiple number(1) not null,
	properties varchar(255) null,
	foreign key (attr_type_id)
		references attr_types(attr_type_id)
			on delete cascade,
	foreign key (attr_group_id)
		references attr_groups(attr_group_id)
			on delete cascade
);


create table params (
	attr_id number not null,
	object_id number not null,
	value varchar(255),
	date_value timestamp,
	show_order varchar(255) not null,
	constraint params_value_not_null check(
		not (value is null and date_value is null)
	),
	foreign key (attr_id)
		references attributes(attr_id)
			on delete cascade,
	foreign key (object_id)
		references objects(object_id)
			on delete cascade
);


create table references (
	attr_id number not null,
	object_id number not null,
	reference number not null,
	show_order varchar(255) not null,
	foreign key (attr_id)
		references attributes(attr_id)
			on delete cascade,
	foreign key (object_id)
		references objects(object_id)
			on delete cascade,
	foreign key (reference)
		references objects(object_id)
			on delete cascade
);


create table attr_binds (
	object_type_id number not null,
	attr_id number not null,
	options varchar(255) null,
	isrequired number(1) not null,
	default_value varchar(255),
	constraint default_value_not_null check(
		isrequired = 1 or default_value is not null 
	),
	primary key (object_type_id, attr_id),
	foreign key (object_type_id)
		references object_types(object_type_id)
			on delete cascade,
	foreign key (attr_id)
		references attributes(attr_id)
			on delete cascade
);

/*			object types
#     Vehicle(0)     Building(3)
#		|				|-------<---Garage(5)
#	   Car(1)   	  Flat(4)
#		|
#	  Coupe(2)
*/
insert into object_types (object_type_id, name) values (0, 'Vehicle');
insert into object_types (object_type_id, parent_id, name)
	values (1, 0, 'Car');
insert into object_types (object_type_id, parent_id, name)
	values (2, 1, 'Coupe');
insert into object_types (object_type_id, name)
	values (3, 'Building');
insert into object_types (object_type_id, parent_id, name)
	values (4, 3, 'Flat');
insert into object_types (object_type_id, parent_id, name)
	values (5, 3, 'Garage');
insert into object_types (object_type_id, name)
	values (6, 'Human');
/*objects
#	Home(0) <- Building
#	  |
#	My Garage(1) <- Garage
#	  |
#	Ford Mustang(2)	<- Coupe	
*/
insert into objects (object_id, object_type_id, name)
	values (0, 4, 'Home');
insert into objects (object_id, parent_id, object_type_id, name)
	values (1, 0, 5, 'My Garage');
insert into objects (object_id, parent_id, object_type_id, name)
	values (2, 1, 2, 'Ford Mustang');
insert into objects (object_id, object_type_id, name)
	values (3, 6, 'Ivan');
/*attr_groups
#
#	Characteristics(0)
#	TenantsInfo(1)
*/
insert into attr_groups values (0, 'Characteristics', 'presentation:list-view');
insert into attr_groups values (1, 'TenantsInfo', 'presentation:table_view');

/*attr_types
#	Area(0)----------->Characteristics
#	Height(1) ----------->---|				TenantsInfo
#	Power(2)  ---------------^				     |
#							 |			  	 	 |
#	Persona(3) ----------------------->----------|
#	Number of People(4) ----------->-------------'
*/
insert into attr_types values (0, 'Area', 'data_type:double');
insert into attr_types values (1, 'Height', 'data_type:double');
insert into attr_types values (2, 'Power', 'data_type:double');
insert into attr_types values (3, 'Persona', 'data_type:object');
insert into attr_types values (4, 'Number of People', 'data_type:integer');

/*attributes
#	TotalArea: Area
#	CeilingHeight: Height
#	EnginePower: Power
#	Owner: Persona (TenantsInfo)
#	TenantNumber: Number of People
#	Driver: Persona (Characteristics)
*/
insert into attributes values (
	0, 0, 0, 'TotalArea', 
	'total area of Building', 0, 'visibility:public'
);
insert into attributes values (
	1, 1, 0, 'CeilingHeight',
	'height between floor and ceiling', 0, 'visibility:public'
);
insert into attributes values (
	2, 2, 0, 'EnginePower',
	'Power of vehicle engine', 0, 'visibility:public'
);
insert into attributes values (
	3, 3, 1, 'Owner',
	'Name of the building owner', 0, 'visibility:authorized'
);
insert into attributes values (
	4, 4, 1, 'TenantNumber',
	'Number of the registered tenants', 0, 'visibility:authorized'
);
insert into attributes values (
	5, 3, 0, 'Drivers',
	'Drivers of this car', 1, 'visibility: private'
);
/*attr_binds
#	TotalArea --------------Building <|-----Flat
#	CeilingHeight-------------|			  	  |
#	Owner---------------------'         	  |
#	Tenants ----------------------------------'
#
#	EnginePower -------------Vehicle <|--
#										|								
#	Driver------------------- Car-------'
*/
insert into attr_binds values (3, 0, null, 1, null);
insert into attr_binds values (3, 1, null, 1, null);
insert into attr_binds values (3, 3, null, 1, null);
insert into attr_binds values (4, 4, null, 1, null);
insert into attr_binds values (0, 2, null, 1, null);
insert into attr_binds values (1, 5, null, 1, null);
insert into attr_binds values (4, 0, null, 0, '13');
insert into attr_binds values (5, 0, null, 0, '17');
/*

Home: {totalArea: 666, ceilingHeight: 13, tenantNumber: 4};
FordMustang: {EnginePower: 540};
*/

insert into params values (0, 0, '666', null, 'none');
insert into params values (1, 0, '13', null, 'none');
insert into params values (2, 2, '540', null, 'none');
insert into params values (4, 0, '4', null, 'none');

/*

Ivan: {};
Home: {owner: Ivan};
FordMustang: {drivers:[Ivan]};

*/

insert into references values (3, 0, 3, 'none');
insert into references values (5, 2, 3, 'ascending');

undefine id;
-- All attributes
/*
		Задание 1: Получение информации обо всех атрибутах
	(учитывая только атрибутную группу и атрибутные типы)
	(attr_id, attr_name, attr_group_id, attr_group_name, 
	attr_type_id, attr_type_name)
		Решение: Несколько джоинов
*/
select 
	attr_id, attr.name as "attr_name", 
	attr_group_id, attr_g.name as "attr_group_name", 
	attr_type_id, attr_t.name as "attr_type_name"
	from attributes attr
	inner join attr_groups attr_g using(attr_group_id)
	inner join attr_types attr_t using (attr_type_id);

-- All attributes for specified object type
/*
		Задание 2: Получение всех атрибутов для заданного 
	объектного типа, без учета наследования(attr_id, attr_name )
		Решение: один джоин attr_binds с attributes
*/
select attr_id, attr.name as "attr_name"
	from attr_binds inner join attributes attr using (attr_id)
		where object_type_id = &id;

--Hierarchy of Object Types from the specified up
/*
		Задание 3: Получение иерархии ОТ(объектных типов) 
	для заданного объектного типа(нужно получить иерархию наследования) 
	(ot_id, ot_name, level)
		Решение: один иерархический запрос
*/
select object_type_id as "ot_id", name as "ot_name", 
		level from object_types
	start with object_type_id = &id
		connect by object_type_id = prior parent_id;

--Hierarchy of Object Types from the specified down
select object_type_id as "ot_id", name as "ot_name", 
		level from object_types
	start with object_type_id = &id
		connect by prior object_type_id = parent_id;
/*
		Задание 4: Получение вложенности объектов для 
	заданного объекта(нужно получить иерархию вложенности)
	(obj_id, obj_name, level)
		Решение: один иерархический запрос
*/
--Hierarchy of embedded objects from the specified up 
select object_id as "obj_id", name as "obj_name", 
		level from objects
	start with object_id = &id
		connect by object_id = prior parent_id;

--Hierarchy of embedded objects from the specified down
select object_id as "obj_id", name as "obj_name", 
		level from objects
	start with object_id = &id
		connect by  prior object_id = parent_id;
/*
		Задание 5: Получение объектов заданного объектного
	типа(учитывая только наследование ОТ)
	(ot_id, ot_name, obj_id, obj_name)
		Решение: Получаем иерархию и джоиним с объектами 
		по object_type_id
*/
--All objects of the same type
select object_type_id as "ot_id", ot.name as "ot_name",
		obj.object_id as "obj_id", obj.name as "obj_name"
from 
	(
		select object_type_id, ot.name from object_types ot
		start with object_type_id = &id
		connect by prior object_type_id = parent_id
	) ot
inner join objects obj using (object_type_id);

--All attributes for the specified object
/*
		Задание 6: Получение значений всех атрибутов
	(всех возможных типов) для заданного объекта
	(без учета наследования ОТ)(attr_id, attr_name, value)
		Решение: Находим тип объекта, находим все его атрибуты,
	выводим сразу две колонки
*/
select attr_id, attr.name as "attr_name", 
		'val: ' || value || ' date_val: ' || date_value as "value"
	from objects obj inner join attr_binds using (object_type_id)
			inner join attributes attr using (attr_id)
			inner join params using (attr_id)
	where obj.object_id = &&id and params.object_id = &&id;

undefine id;
--All references to the specified object
/*
		Задание 7: Получение ссылок на заданный объект
	(все объекты, которые ссылаются на текущий)(ref_id, ref_name)
		Решение: Выбираем все записи из references, у которых
	ссылка на заданный объект
*/
select object_id as "ref_id", objects.name as "ref_name"
	from 
	(
		select references.object_id
		from references
		where references.reference = &id
	) inner join objects using (object_id);

--All attirbutes for the specified objects (including inheritance)
/*
		Задание 8: Получение значений всех атрибутов
	(всех возможных типов, без повторяющихся атрибутов) 
	для заданного объекта( с учетом наследования ОТ)
	Вывести в виде (attr_id, attr_name, value)
		Решение: в таблице tmp храним уникальные attr_id:
	Получаем иеархию типов вверх от типа заданного объекта,
	объединяем с attr_binds по полю object_type_id и выбираем
	все уникальные attr_id. После этого выбираем из таблицы 
	params все записи, в которых фигурируют найденные attr_id
	и у которых object_id равен заданному объекту.
*/
with tmp as (
	select distinct attr_id from 
	(
		select object_type_id 
		from object_types ot
		start with object_type_id in 
		(	
			select object_type_id 
			from objects 
			where object_id = &&id
		)
		connect by object_type_id = prior parent_id
	)
	inner join attr_binds using (object_type_id)
)
select attr_id, attr.name as "attr_name",
		'val: ' || value || ' date_val: ' || date_value as "value"
from tmp inner join attributes attr using (attr_id)
	inner join params prms using (attr_id)
where prms.object_id = &&id;
undefine id;