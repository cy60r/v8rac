#Использовать v8find
#Использовать logos
#Использовать 1commands

Перем Лог;
Перем ПутьКлиентаАдминистрирования;
Перем ЭтоWindows;

Перем АвторизацияАдминистратораКластера;
Перем АдресСервера;
Перем ПортСервера;

Перем ИндексЛокальныхКластеров;
Перем ИндексИнформационныхБаз;

Перем ИндексЛокальныхКластеровОбновлен;
Перем ИндексАвторизацийИнформационныхБаз;

Перем ИмяКлючаВсеБазы;
Перем КластерПодключен;

// Устанавливает авторизацию на кластере 1С
//
// Параметры:
//   Пользователь - Строка - администратор кластера
//   Пароль - Строка - пароль администратора кластера
//
Процедура УстановитьАвторизациюКластера(Знач Пользователь, Знач Пароль = "") Экспорт
	
	АвторизацияАдминистратораКластера = Новый Структура("Пользователь, Пароль", Пользователь, Пароль);

КонецПроцедуры

// Устанавливает авторизацию для информационной базы на кластере 1С
//
// Параметры:
//   ИнформационнаяБаза - Строка - имя или uid информационной базы 
//   Пользователь - Строка - администратор информационной базы
//   Пароль - Строка - пароль администратора информационной базы
//
Процедура УстановитьАвторизациюИнформационнойБазы(Знач ИнформационнаяБаза, Знач Пользователь, Знач Пароль = "") Экспорт
	
	АвторизацияИБ = Новый Структура("Пользователь, Пароль", Пользователь, Пароль);

	ИндексАвторизацийИнформационныхБаз.Вставить(ИнформационнаяБаза, АвторизацияИБ);

КонецПроцедуры

// Устанавливает кластер 1С
//
// Параметры:
//   АдресСерверКластера - Строка - адрес кластера
//   ПортСервераКластера - Число - порт кластера (по умолчанию 1545)
//   ПринудительноСброситьИндексы - Булево - признак необходимости сброса кеша данных кластера (по умолчанию ложь)
//
Процедура УстановитьКластер(Знач АдресСерверКластера, Знач ПортСервераКластера = 1545, Знач ПринудительноСброситьИндексы = Ложь) Экспорт
	
	ИзменилсяКластер = Ложь;

	ТекущийАдресКластера = АдресСервера;
	ТекущийПортКластера = ПортСервера;

	МассивСтрок = СтрРазделить(АдресСерверКластера, ":");

	Если МассивСтрок.Количество() = 2 Тогда
		АдресСервера = МассивСтрок[0];
		ПортСервера = МассивСтрок[1];
	Иначе
		АдресСервера = АдресСерверКластера;
		ПортСервера = ПортСервераКластера;
	КонецЕсли;

	ИзменилсяКластер = НЕ ТекущийАдресКластера = АдресСервера
					   ИЛИ НЕ ТекущийПортКластера = ПортСервера;

	Если ПринудительноСброситьИндексы 
		ИЛИ ИзменилсяКластер Тогда
		КластерПодключен = Ложь;
		СброситьИндексы();
		
	КонецЕсли;

КонецПроцедуры

// Возвращает список локальных кластеров 
//
//  Возвращаемое значение:
//   Массив - список UID локальных кластеров
//
Функция СписокЛокальныхКластеров() Экспорт
	
	Если Не ИндексЛокальныхКластеровОбновлен Тогда
		ОбновитьИндексЛокальныхКластеров();
	КонецЕсли;

	СписокКластеров = Новый Массив();

	Для каждого КлючЗначение Из ИндексЛокальныхКластеров Цикл
		СписокКластеров.Добавить(КлючЗначение.Ключ);
	КонецЦикла;

	Возврат СписокКластеров;
	
КонецФункции

// Выполняет подключение к кластеру 1С
//
Процедура Подключить() Экспорт

	КластерПодключен = Истина;

	ОбновитьДанные(Истина);

КонецПроцедуры

// Устанавливает версию платформы для использования
//
// Параметры:
//   ВерсияПлатформы - Строка - версия платформы 1С в формfте <8.3.13.1513>
//
Процедура ИспользоватьВерсию(Знач ВерсияПлатформы) Экспорт

	ПутьКлиентаАдминистрирования = ПолучитьПутьКRAC(ВерсияПлатформы);

КонецПроцедуры

// Выполняет обновление данных индексов текущего кластера
//
// Параметры:
//   ОбновитьПринудительно - Булево - признак принудительного обновления
//
Процедура ОбновитьДанные(Знач ОбновитьПринудительно = Ложь) Экспорт
	
	Если ИндексЛокальныхКластеровОбновлен
		И НЕ ОбновитьПринудительно Тогда
		Возврат
	КонецЕсли;
	
	ОбновитьИндексЛокальныхКластеров();

	МассивКластеров = Новый Массив;

	Для каждого Кластер Из ИндексЛокальныхКластеров Цикл
		МассивКластеров.Добавить(Кластер.Ключ);
	КонецЦикла;
	
	Для каждого Кластер Из МассивКластеров Цикл
		ОбновитьИндексИнформационныхБаз(Кластер, ОбновитьПринудительно);
	КонецЦикла;
	
КонецПроцедуры

// Возвращает таблицу информационных баз локального кластера
//
// Параметры:
//   ИдентификаторКластера - Строка, Неопределено - идентификатор локального кластера
//
// Возвращаемое значение:
//   ТаблицаЗначений - список информационных баз, колонки
//	  * Имя - Строка - имя информационной базы на кластере
//	  * UID - Строка - идентификатор информационной базы на кластере
//	  * Кластер - Строка - идентификатор кластера
//
Функция СписокИнформационныхБаз(Знач ИдентификаторКластера = Неопределено) Экспорт
	
	ТаблицаИнформационныхБазы = Новый ТаблицаЗначений();
	ТаблицаИнформационныхБазы.Колонки.Добавить("Имя");
	ТаблицаИнформационныхБазы.Колонки.Добавить("UID");
	ТаблицаИнформационныхБазы.Колонки.Добавить("Кластер");

	Для каждого КлючЗначение Из ИндексИнформационныхБаз Цикл

		ОписаниеИБ = КлючЗначение.Значение;

		Если ЗначениеЗаполнено(ИдентификаторКластера)
			И Не ИдентификаторКластера = ОписаниеИБ.Кластер Тогда
			Продолжить;
		КонецЕсли;

		ЗаполнитьЗначенияСвойств(ТаблицаИнформационныхБазы.Добавить(), ОписаниеИБ);
	КонецЦикла;

	Возврат ТаблицаИнформационныхБазы;

КонецФункции

// Возвращает таблицу сеансов информационной базы
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы
//
// Возвращаемое значение:
//   ТаблицаЗначений - список сеансов информационной базы
//    * Идентификатор - Строка - идентификатор сеанса
//    * Приложение - Строка - имя приложения сеанса
//    * Пользователь - Строка - пользователь сеанса
//    * НомерСеанса - Строка - номер сеанса
//    * ИнформационнаяБаза - Строка - идентификатор информационной базы
//    * Кластер - Строка - идентификатор локального кластера
//
Функция СписокСеансовИнформационнойБазы(Знач ИнформационнаяБаза) Экспорт

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		Возврат ПолучитьТаблицуСеансов();
	КонецЕсли;
	
	Возврат СписокСеансовКластера(ОписаниеИБ.Кластер, ОписаниеИБ.UID);
	
КонецФункции

// Возвращает таблицу сеансов локального кластера
//
// Параметры:
//   ИдентификаторКластера - Строка - идентификатор локального кластера
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы (по умолчанию неопределено)
//
// Возвращаемое значение:
//   ТаблицаЗначений - список сеансов информационной базы
//    * Идентификатор - Строка - идентификатор сеанса
//    * Приложение - Строка - имя приложения сеанса
//    * Пользователь - Строка - пользователь сеанса
//    * НомерСеанса - Строка - номер сеанса
//    * ИнформационнаяБаза - Строка - идентификатор информационной базы
//    * Кластер - Строка - идентификатор локального кластера
//
Функция СписокСеансовКластера(Знач ИдентификаторКластера, Знач ИнформационнаяБаза = Неопределено) Экспорт
	
	ТаблицаСеансов = ПолучитьТаблицуСеансов();
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("session");
	Параметры.Добавить("list");

	Если ЗначениеЗаполнено(ИнформационнаяБаза) Тогда
		Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	КонецЕсли;

	Параметры.Добавить(КлючИдентификатораКластера(ИдентификаторКластера));

	СписокСеансовИБ = ВыполнитьКоманду(Параметры);	
	
	Данные = РазобратьПотокВывода(СписокСеансовИБ);
	
	Для Каждого Элемент Из Данные Цикл
		
		Если НРег(Элемент["app-id"]) = НРег("RAS")
			ИЛИ НРег(Элемент["app-id"]) = НРег("SrvrConsole")
			ИЛИ НРег(Элемент["app-id"]) = НРег("JobScheduler")
			Тогда
			Продолжить;
		КонецЕсли;

		ТекСтрока = ТаблицаСеансов.Добавить();
		ТекСтрока.Идентификатор = Элемент["session"];
		ТекСтрока.Пользователь  = Элемент["user-name"];
		ТекСтрока.Приложение    = Элемент["app-id"];
		ТекСтрока.НомерСеанса   = Элемент["session-id"];
		ТекСтрока.ИнформационнаяБаза = Элемент["infobase"];
		ТекСтрока.Кластер = ИдентификаторКластера;
		
	КонецЦикла;
	
	Возврат ТаблицаСеансов;
	
КонецФункции

// Возвращает таблицу соединений информационной базы
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы (по умолчанию неопределено)
//
// Возвращаемое значение:
//   ТаблицаЗначений - список соединений информационной базы
//    * Идентификатор - Строка - идентификатор соединения
//    * Приложение - Строка - имя приложения соединения
//    * Процесс - Строка - идентификатор процесса соединения
//    * НомерСоединения - Строка - номер соединения
//    * ИнформационнаяБаза - Строка - идентификатор информационной базы
//    * Кластер - Строка - идентификатор локального кластера
//
Функция СписокСоединенийИнформационнойБазы(Знач ИнформационнаяБаза) Экспорт
	
	ТаблицаСоединений = ПолучитьТаблицуСоединенийРабочегоПроцесса();
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("connection");
	Параметры.Добавить("list");
	
	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		Возврат ТаблицаСоединений;
	КонецЕсли;
	
	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));

	ИдентификаторКластера = ОписаниеИБ.Кластер;

	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	СписокСоединенийИБ = ВыполнитьКоманду(Параметры);	
	
	Данные = РазобратьПотокВывода(СписокСоединенийИБ);
	
	Для Каждого Элемент Из Данные Цикл
		
		// Лог.ПоляИз(Элемент).Отладка("Получено соединение");

		Если НРег(Элемент["application"]) = НРег("RAS")
			ИЛИ НРег(Элемент["application"]) = НРег("SrvrConsole") 
			ИЛИ НРег(Элемент["application"]) = НРег("JobScheduler")
			Тогда
			Продолжить;
		КонецЕсли;

		Если Строка(Элемент["conn-id"]) = "0" Тогда
			Продолжить; // Не существующие соединение
		КонецЕсли;

		ТекСтрока = ТаблицаСоединений.Добавить();
		ТекСтрока.Идентификатор 		= Элемент["connection"];
		ТекСтрока.Процесс  				= Элемент["process"];
		ТекСтрока.Приложение    		= Элемент["application"];
		ТекСтрока.НомерСоединения   	= Элемент["conn-id"];
		ТекСтрока.ИнформационнаяБаза 	= Элемент["infobase"];
		ТекСтрока.Кластер 				= ИдентификаторКластера;
		
	КонецЦикла;
	
	Возврат ТаблицаСоединений;
	
КонецФункции

// Выполняет отключение сеансов информационной базы
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы
//   Фильтр - Структура - фильтр структура исключений при отключении (по умолчанию неопределено)
//						  * Ключ - имя поля для поиска
//						  * Значение - массив значений фильтра
//
Процедура ОтключитьСеансыИнформационнойБазы(Знач ИнформационнаяБаза, Знач Фильтр = Неопределено) Экспорт

	Лог.Отладка("Отключаю существующие сеансы");

	СеансыБазы = СписокСеансовИнформационнойБазы(ИнформационнаяБаза);
	
	Для Каждого Сеанс Из СеансыБазы Цикл
		
		Если ВФильтре(Сеанс, Фильтр) Тогда
			Продолжить;
		КонецЕсли;
		
		Лог.Отладка("Отключаю сеанс %3 - <%1>, <%2>", Сеанс.Пользователь, Сеанс.Приложение, Сеанс.НомерСеанса );

		Попытка
			ОтключитьСеанс(Сеанс.Идентификатор, Сеанс.Кластер);
		Исключение
			Лог.Ошибка(ОписаниеОшибки());
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

// Выполняет отключение соединений информационной базы
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы 
//   Фильтр - Структура - фильтр структура исключений при отключении (по умолчанию неопределено)
//						  * Ключ - имя поля для поиска
//						  * Значение - массив значений фильтра
//
Процедура ОтключитьСоединенияИнформационнойБазы(Знач ИнформационнаяБаза, Знач Фильтр = Неопределено) Экспорт

	Лог.Отладка("Отключаю существующие соединения");

	СоединенияБазы = СписокСоединенийИнформационнойБазы(ИнформационнаяБаза);
	
	Для Каждого Соединение Из СоединенияБазы Цикл
		
		Если ВФильтре(Соединение, Фильтр) Тогда
			Продолжить;
		КонецЕсли;

		Лог.Отладка("Отключаю соединение %3 - <%1>, <%2>", Соединение.Идентификатор, Соединение.Приложение, Соединение.НомерСоединения);
		
		Попытка
			ОтключитьСоединение(Соединение.Идентификатор, Соединение.Процесс, Соединение.Кластер, Соединение.ИнформационнаяБаза);
		Исключение
			Лог.Ошибка(ОписаниеОшибки());
		КонецПопытки;

	КонецЦикла;
	
КонецПроцедуры

// Получает и возвращает подробное описание информационной базы
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы 
//   АвторизацияИБ - Структура, Неопределено - авторизация в информационной базе 
//								 * Пользователь - Строка - администратор информационной базы
//								 * Пароль - Строка - пароль администратора информационной базы
//
// Возвращаемое значение:
//   Структура - подробное описание информационной базы
//    * Кластер - Строка - идентификатор локального кластера
//    * Наименование - Строка - наименование базы
//    * Описание - Строка - описание базы
//    * ТипСУБД - Строка - тип СУБД 
//    * АдресСервераСУБД - Строка - адрес сервера СУБД
//    * БазаДанныхСУБД - Строка - база данных на сервере СУБД
//    * ПользовательСУБД - Строка - пользователь базы данных СУБД
//    * ЗапретРегламентныхЗаданий - Булево - текущее состояние запрета регламентных заданий
//    * ЗапретПодключенияСессий - Булево - текущее состояние запрета подключения сессий
//
Функция ПолучитьПодробноеОписаниеИнформационнойБазы(Знач ИнформационнаяБаза, Знач АвторизацияИБ = Неопределено) Экспорт
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("info");

	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если Не АвторизацияИБ = Неопределено Тогда

		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			Параметры.Добавить(СтрШаблон("--infobase-user=%1", ОбернутьВКавычки(АвторизацияИБ.Пользователь)));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				Параметры.Добавить(СтрШаблон("--infobase-pwd=%2", ОбернутьВКавычки(АвторизацияИБ.Пароль)));
			КонецЕсли;	
		КонецЕсли;
	Иначе

		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);		
	
	КонецЕсли;

	ПотокДанных = ВыполнитьКоманду(Параметры);

	МассивДанных = РазобратьПотокВывода(ПотокДанных);
	ПодробноеОписаниеИБ = Новый Структура();
	
	Если МассивДанных.Количество() = 0 Тогда
		Возврат ПодробноеОписаниеИБ;
	КонецЕсли;
	Данные = МассивДанных[0];

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	ПодробноеОписаниеИБ.Вставить("Кластер", ОписаниеИБ.Кластер);
	ПодробноеОписаниеИБ.Вставить("Наименование", Данные["name"]);
	ПодробноеОписаниеИБ.Вставить("Описание", Данные["descr"]);
	ПодробноеОписаниеИБ.Вставить("ТипСУБД", Данные["dbms"]);
	ПодробноеОписаниеИБ.Вставить("АдресСервераСУБД", Данные["db-server"]);
	ПодробноеОписаниеИБ.Вставить("БазаДанныхСУБД", Данные["db-name"]);
	ПодробноеОписаниеИБ.Вставить("ПользовательСУБД", Данные["db-user"]);
	ПодробноеОписаниеИБ.Вставить("ЗапретРегламентныхЗаданий", ?(Данные["scheduled-jobs-deny"] = "on", Истина, Ложь));
	ПодробноеОписаниеИБ.Вставить("ЗапретПодключенияСессий", ?(Данные["sessions-deny"] = "on", Истина, Ложь));

	Возврат ПодробноеОписаниеИБ;

КонецФункции

// Выполняет отключение сеанса по индентификаторы
//
// Параметры:
//   ИдентификаторСеанса - Строка - идентификатор сеанса
//   ИдентификаторКластер - Строка - идентификатор локального кластера
//
Процедура ОтключитьСеанс(Знач ИдентификаторСеанса, Знач ИдентификаторКластер) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("session");
	Параметры.Добавить("terminate");
	Параметры.Добавить(КлючИдентификатораКластера(ИдентификаторКластер));

	Параметры.Добавить(СтрШаблон("--session=""%1""", ИдентификаторСеанса));
	
	ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Выполняет отключение соединения по идентификатору
//
// Параметры:
//   ИдентификаторСоединения - Строка - идентификатор соединения
//   ИдентификаторПроцесса - Строка - идентификатор рабочего процесса
//   ИдентификаторКластер - Строка - идентификатор локального кластера
//   ИнформационнаяБаза - Строка, Неопределено - Имя или идентификатор информационной базы 
//
Процедура ОтключитьСоединение(Знач ИдентификаторСоединения, Знач ИдентификаторПроцесса, Знач ИдентификаторКластер, Знач ИнформационнаяБаза = Неопределено) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("connection");
	Параметры.Добавить("disconnect");
	Параметры.Добавить(КлючИдентификатораКластера(ИдентификаторКластер));
	Параметры.Добавить(СтрШаблон("--process=%1", ИдентификаторПроцесса));
	Параметры.Добавить(СтрШаблон("--connection=%1", ИдентификаторСоединения));
	
	Если ЗначениеЗаполнено(ИнформационнаяБаза) Тогда
		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);			
	КонецЕсли;

	ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Снимает блокировку с информационной базы
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы 
//   ОставитьБлокировкуРеглЗаданий - Булево - признак блокировки регламентных заданий
//   АвторизацияИБ - Структура, Неопределено - авторизация в информационной базе 
//								 * Пользователь - Строка - администратор информационной базы
//								 * Пароль - Строка - пароль администратора информационной базы
//
Процедура СнятьБлокировкуИнформационнойБазы(Знач ИнформационнаяБаза, 
											Знач ОставитьБлокировкуРеглЗаданий = Ложь,
											Знач АвторизацияИБ = Неопределено) Экспорт
	
	ПараметрыИнформационнойБазы = Новый Соответствие();

	Если Не АвторизацияИБ = Неопределено Тогда
		
		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			ПараметрыИнформационнойБазы.Вставить("--infobase-user", ОбернутьВКавычки(АвторизацияИБ.Пользователь));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				ПараметрыИнформационнойБазы.Добавить("--infobase-pwd", ОбернутьВКавычки(АвторизацияИБ.Пароль));
			КонецЕсли;	
		КонецЕсли;
	
	КонецЕсли;

	ПараметрыИнформационнойБазы.Вставить("--sessions-deny", "off");

	Если НЕ ОставитьБлокировкуРеглЗаданий Тогда
		ПараметрыИнформационнойБазы.Вставить("--scheduled-jobs-deny", "off");	
	КонецЕсли;

	ПараметрыИнформационнойБазы.Вставить("--denied-message", ОбернутьВКавычки(""));
	ПараметрыИнформационнойБазы.Вставить("--permission-code", ОбернутьВКавычки(""));
	ПараметрыИнформационнойБазы.Вставить("--denied-from", ОбернутьВКавычки(""));
	ПараметрыИнформационнойБазы.Вставить("--denied-to", ОбернутьВКавычки(""));
	
	ОбновитьПараметрыИнформационнойБазы(ИнформационнаяБаза, ПараметрыИнформационнойБазы);	

КонецПроцедуры

// Выполняет поиск информационной базы в кластере 1С
//
// Параметры:
//   ИмяБазы - Строка - имя информационной базы в кластере 1С
//
//  Возвращаемое значение:
//   Строка - пустая строка, если база не найдена, или идентификатор базы 
//
Функция НайтиИнформационнуюБазу(Знач ИмяБазы) Экспорт
	
	ОписаниеИБ = ИндексИнформационныхБаз[ИмяБазы];
	
	Если ОписаниеИБ = Неопределено Тогда
		Возврат "";
	КонецЕсли;

	ИдентификаторБазы = ОписаниеИБ.UID;

	Возврат ИдентификаторБазы;

КонецФункции

// Создает информационную базу на кластере
//
// Параметры:
//   Кластер - Строка - идентификатор локального кластера
//   Наименование - Строка - наименование базы
//   ТипСУБД - Строка - тип СУБД 
//   АдресСервераСУБД - Строка - адрес сервера СУБД
//   БазаДанныхСУБД - Строка - база данных на сервере СУБД
//   ПользовательСУБД - Строка - пользователь базы данных СУБД
//   ПарольСУБД - Строка - пароль пользователя базы данных СУБД
//   ЛокальИБ - Строка - локаль базы данных СУБД
//   СмещениеДат - Число - смещение даны на СУБД
//   Описание - Строка - описание базы
//   БлокировкаРеглЗаданий - Булево - признак установки блокировки регламентных заданий
//   СоздатьБазуДанных - Булево - признак создания базы данных на СУБД
//
//  Возвращаемое значение:
//   Строка - идентификатор созданный информационной базы
//
Функция СоздатьИнформационнуюБазу(Знач Кластер,
									Знач Наименование, 
									Знач ТипСУБД,
									Знач АдресСервераСУБД,
									Знач БазаДанныхСУБД,
									Знач ПользовательСУБД = "",
									Знач ПарольСУБД = "",
									Знач ЛокальИБ = "RU",
									Знач СмещениеДат = 0,
									Знач Описание = "",
									Знач БлокировкаРеглЗаданий = Ложь,
									Знач СоздатьБазуДанных = Ложь
									) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("create");

	Параметры.Добавить(КлючИдентификатораКластера(Кластер));

	Параметры.Добавить("--name=" + Наименование);

	Параметры.Добавить("--dbms=" + ТипСУБД);
	Параметры.Добавить("--db-server=" + АдресСервераСУБД);
	Параметры.Добавить("--db-name=" + БазаДанныхСУБД);
	
	Если ЗначениеЗаполнено(ПользовательСУБД) Тогда
		Параметры.Добавить("--db-user=" + ПользовательСУБД);

		Если ЗначениеЗаполнено(ПарольСУБД) Тогда
			Параметры.Добавить("--db-pwd=" + ПарольСУБД);
		КонецЕсли;

	КонецЕсли;

	Если СоздатьБазуДанных Тогда
		Параметры.Добавить("--create-database");
	КонецЕсли;

	Параметры.Добавить("--locale=" + ЛокальИБ);
	Параметры.Добавить("--scheduled-jobs-deny=" + ?(БлокировкаРеглЗаданий, "on", "off"));

	Если ЗначениеЗаполнено(Описание) Тогда
		Параметры.Добавить("--descr=" + ОбернутьВКавычки(Описание));
	КонецЕсли;
			
	Если ЗначениеЗаполнено(СмещениеДат) Тогда
		Параметры.Добавить("--date-offset=" + Строка(СмещениеДат));
	КонецЕсли;

	Данные = РазобратьПотокВывода(ВыполнитьКоманду(Параметры));

	ИдентификаторБазы = Данные[0]["infobase"];
	ОписаниеИБ = ОписаниеИнформационнойБазы(Наименование, ИдентификаторБазы, Кластер);
	ИндексИнформационныхБаз.Вставить(ИдентификаторБазы, ОписаниеИБ);
	ИндексИнформационныхБаз.Вставить(Наименование, ОписаниеИБ);

	Возврат ИдентификаторБазы;

КонецФункции

// Удаляет информационную базу
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы 
//   ОчиститьБазуДанных - Булево - признак очистки базы данных на СУБД
//   УдалитьБазуДанных - Булево - признак удаления базы данных на СУБД
//   АвторизацияИБ - Структура, Неопределено - авторизация в информационной базе 
//								 * Пользователь - Строка - администратор информационной базы
//								 * Пароль - Строка - пароль администратора информационной базы
//
Процедура УдалитьИнформационнуюБазу(Знач ИнформационнаяБаза,
									Знач ОчиститьБазуДанных = Ложь,
									Знач УдалитьБазуДанных = Ложь,
									Знач АвторизацияИБ = Неопределено) Экспорт
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("drop");

	Если УдалитьБазуДанных Тогда
		Параметры.Добавить("--drop-database");
	ИначеЕсли ОчиститьБазуДанных Тогда
		Параметры.Добавить("--clear-database");
	КонецЕсли;

	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если Не АвторизацияИБ = Неопределено Тогда

		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			Параметры.Добавить(СтрШаблон("--infobase-user=%1", ОбернутьВКавычки(АвторизацияИБ.Пользователь)));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				Параметры.Добавить(СтрШаблон("--infobase-pwd=%2", ОбернутьВКавычки(АвторизацияИБ.Пароль)));
			КонецЕсли;	
		КонецЕсли;
	Иначе

		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);		
	
	КонецЕсли;

	ВыполнитьКоманду(Параметры);

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];
	
	Если НЕ ОписаниеИБ = Неопределено Тогда
		
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.UID);
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.Имя);

	КонецЕсли;

КонецПроцедуры

// Устанавливает блокировку на информационную базу
//
// Параметры:
//   ИнформационнаяБаза - Строка - Имя или идентификатор информационной базы 
//   СообщениеОБлокировке - Строка - сообщение блокировки для пользователей
//   КлючРазрешенияЗапуска - Строка - ключ разрешения входа в информационную базу
//   ДатаНачалаБлокировки - Дата, Неопределено - дата начала блокировки 
//   ДатаОкончанияБлокировки - Дата, Неопределено - дата окончания блокировки 
//   БлокировкаРеглЗаданий - Булево - признак блокировки регламентных заданий (по умолчанию Ложь)
//   АвторизацияИБ - Структура, Неопределено - авторизация в информационной базе 
//								 * Пользователь - Строка - администратор информационной базы
//								 * Пароль - Строка - пароль администратора информационной базы
//
Процедура БлокировкаИнформационнойБазы(Знач ИнформационнаяБаза, 
										Знач СообщениеОБлокировке = "",
										Знач КлючРазрешенияЗапуска = "",
										Знач ДатаНачалаБлокировки = Неопределено
										Знач ДатаОкончанияБлокировки = Неопределено,
										Знач БлокировкаРеглЗаданий = Ложь,
										Знач АвторизацияИБ = Неопределено) Экспорт
	
	ПараметрыИнформационнойБазы = Новый Соответствие();

	Если Не АвторизацияИБ = Неопределено Тогда
		
		Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
			ПараметрыИнформационнойБазы.Вставить("--infobase-user", ОбернутьВКавычки(АвторизацияИБ.Пользователь));
			Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
				ПараметрыИнформационнойБазы.Добавить("--infobase-pwd", ОбернутьВКавычки(АвторизацияИБ.Пароль));
			КонецЕсли;	
		КонецЕсли;
	
	КонецЕсли;

	ПараметрыИнформационнойБазы.Вставить("--sessions-deny", "on");

	Если БлокировкаРеглЗаданий Тогда
		ПараметрыИнформационнойБазы.Вставить("--scheduled-jobs-deny", "on");	
	КонецЕсли;

	Если ЗначениеЗаполнено(СообщениеОБлокировке) Тогда
		ПараметрыИнформационнойБазы.Вставить("--denied-message", ОбернутьВКавычки(СообщениеОБлокировке));
	КонецЕсли;

	Если ЗначениеЗаполнено(КлючРазрешенияЗапуска) Тогда
		ПараметрыИнформационнойБазы.Вставить("--permission-code", ОбернутьВКавычки(КлючРазрешенияЗапуска));
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДатаНачалаБлокировки) Тогда
		ПараметрыИнформационнойБазы.Вставить("--denied-from", ФорматДатыISO(ДатаНачалаБлокировки));
	КонецЕсли;

	Если ЗначениеЗаполнено(ДатаОкончанияБлокировки) Тогда
		ПараметрыИнформационнойБазы.Вставить("--denied-to", ФорматДатыISO(ДатаОкончанияБлокировки));
	КонецЕсли;

	ОбновитьПараметрыИнформационнойБазы(ИнформационнаяБаза, ПараметрыИнформационнойБазы);

КонецПроцедуры

// Выполняет блокировку регламентных заданий
//
// Параметры:
//   ИнформационнаяБаза - Строка, Неопределено - Имя или идентификатор информационной базы
//
Процедура БлокировкаРегламентныхЗаданий(ИнформационнаяБаза) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("update");
	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если ЗначениеЗаполнено(ИнформационнаяБаза) Тогда
		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);			
	КонецЕсли;

	Параметры.Добавить(СтрШаблон("--scheduled-jobs-deny=""%1""", "on"));

	ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Отменяет блокировку регламентных заданий
//
// Параметры:
//   ИнформационнаяБаза - Строка, Неопределено - Имя или идентификатор информационной базы
//
Процедура СнятьБлокировкуРегламентныхЗаданий(ИнформационнаяБаза) Экспорт

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("update");
	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если ЗначениеЗаполнено(ИнформационнаяБаза) Тогда
		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);			
	КонецЕсли;

	Параметры.Добавить(СтрШаблон("--scheduled-jobs-deny=""%1""", "off"));

	ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Выполняет команды на кластере 1С
//
// Параметры:
//   ПараметрыКоманды - Массив - массив параметров команды 
//
//  Возвращаемое значение:
//   Строка - результат выполнения команды на кластере 1С
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт

	Если Не КластерПодключен Тогда
		ВызватьИсключение "Необходимо сначала выполнить подключение к кластеру 1С";
	КонецЕсли;

	КомандаВыполнения = ПутьКлиентаАдминистрирования;
	АдресСервераАдминистрирования = СтрШаблон("%1:%2", АдресСервера, ПортСервера);
	
	Команда = Новый Команда();
	Команда.УстановитьКоманду(КомандаВыполнения);

	Если ЕстьПараметр(ПараметрыКоманды, "--cluster") Тогда
		ДобавитьПараметрыАвторизацииКластера(ПараметрыКоманды);
	КонецЕсли;

	Команда.ДобавитьПараметры(ПараметрыКоманды);

	Команда.ДобавитьПараметр(АдресСервераАдминистрирования);
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	КодВозврата = Команда.Исполнить();

	Если КодВозврата <> 0 Тогда
		ВызватьИсключение Команда.ПолучитьВывод();
	КонецЕсли;

	Возврат Команда.ПолучитьВывод();
	
КонецФункции

#Область Поиск_версии_платформы

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Процедура ОбновитьПараметрыИнформационнойБазы(Знач ИнформационнаяБаза, Знач ПараметрыИнформационнойБазы)

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("update");

	Параметры.Добавить(КлючИдентификатораБазы(ИнформационнаяБаза));
	Параметры.Добавить(КлючИдентификатораКластераБазы(ИнформационнаяБаза));

	Если ПараметрыИнформационнойБазы["--infobase-user"] = Неопределено Тогда
		ДобавитьПараметрыАвторизацииИнформационнойБазы(Параметры, ИнформационнаяБаза);		
	КонецЕсли;

	Для каждого КлючЗначение Из ПараметрыИнформационнойБазы Цикл
		Параметры.Добавить(СтрШаблон("%1=%2", КлючЗначение.Ключ, КлючЗначение.Значение));		
	КонецЦикла;

	ВыполнитьКоманду(Параметры)
	
КонецПроцедуры

Процедура СброситьИндексы()
	
	ИндексЛокальныхКластеров = Новый Соответствие();
	ИндексИнформационныхБаз = Новый Соответствие();
	ИндексЛокальныхКластеровОбновлен = Ложь;

КонецПроцедуры

Функция ПолучитьТаблицуСоединенийРабочегоПроцесса()
		
	ТаблицаСоединенийРабочегоПроцесса = Новый ТаблицаЗначений;
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Идентификатор");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Приложение");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Процесс");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("НомерСоединения");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("ИнформационнаяБаза");
	ТаблицаСоединенийРабочегоПроцесса.Колонки.Добавить("Кластер");
	
	Возврат ТаблицаСоединенийРабочегоПроцесса;

КонецФункции

Функция ПолучитьТаблицуСеансов()
	
	ТаблицаСеансов = Новый ТаблицаЗначений;
	ТаблицаСеансов.Колонки.Добавить("Идентификатор");
	ТаблицаСеансов.Колонки.Добавить("Приложение");
	ТаблицаСеансов.Колонки.Добавить("Пользователь");
	ТаблицаСеансов.Колонки.Добавить("НомерСеанса");
	ТаблицаСеансов.Колонки.Добавить("ИнформационнаяБаза");
	ТаблицаСеансов.Колонки.Добавить("Кластер");
	
	Возврат ТаблицаСеансов;

КонецФункции

Функция ОписаниеИнформационнойБазы(Знач ИмяБазы, Знач UID, Знач Кластер)
	
	ОписаниеИБ = Новый Структура();
	ОписаниеИБ.Вставить("Имя", ИмяБазы);
	ОписаниеИБ.Вставить("UID", UID);
	ОписаниеИБ.Вставить("Кластер", Кластер);

	Возврат ОписаниеИБ;

КонецФункции

Функция ФорматДатыISO(Знач ВходящаяДата)
	
	ФорматДаты = "ДФ='yyyy-MM-ddTHH:mm:ss'";

	Возврат Формат(ВходящаяДата, ФорматДаты);

КонецФункции

Функция ОбернутьВКавычки(Знач Строка)

	Результат = """" + Строка + """";

	Возврат Результат;

КонецФункции

Функция ПолучитьПутьКRAC(Знач ВерсияПлатформы = "")
	
	Если ПустаяСтрока(ВерсияПлатформы) Тогда 
		ВерсияПлатформы = "8.3";
	КонецЕсли;
	
	ПутьКRAC = Платформа1С.ПутьКRAC(ВерсияПлатформы);

	Возврат ПутьКRAC;
	
КонецФункции

Процедура ДобавитьПараметрыАвторизацииКластера(Знач ПараметрыЗапуска)
	
	Если ЗначениеЗаполнено(АвторизацияАдминистратораКластера.Пользователь) Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--cluster-user=""%1""", АвторизацияАдминистратораКластера.Пользователь));
		Если ЗначениеЗаполнено(АвторизацияАдминистратораКластера.Пароль) Тогда
			ПараметрыЗапуска.Добавить(СтрШаблон("--cluster-pwd=""%1""", АвторизацияАдминистратораКластера.Пароль));
		КонецЕсли;	
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьПараметрыАвторизацииИнформационнойБазы(Знач ПараметрыЗапуска, Знач ИнформационнаяБаза)
	
	АвторизацияИБ = ИндексАвторизацийИнформационныхБаз[ИнформационнаяБаза];
	
	Если АвторизацияИБ = Неопределено Тогда
		АвторизацияИБ = ИндексАвторизацийИнформационныхБаз[ИмяКлючаВсеБазы];
	КонецЕсли;

	Если АвторизацияИБ = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ЗначениеЗаполнено(АвторизацияИБ.Пользователь) Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--infobase-user=""%1""", АвторизацияИБ.Пользователь));
		Если ЗначениеЗаполнено(АвторизацияИБ.Пароль) Тогда
			ПараметрыЗапуска.Добавить(СтрШаблон("--infobase-pwd=""%1""", АвторизацияИБ.Пароль));
		КонецЕсли;	
	КонецЕсли;

КонецПроцедуры

Функция СтандартныеПараметрыЗапуска()
	
	ПараметрыЗапуска = Новый Массив;
	
	Возврат ПараметрыЗапуска; 

КонецФункции

Функция КлючИдентификатораКластера(Знач Кластер)

	ИдентификаторКластера = Кластер;

	Возврат СтрШаблон("--cluster=%1", ИдентификаторКластера);
	
КонецФункции

Функция КлючИдентификатораБазы(Знач ИнформационнаяБаза)

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		ВызватьИсключение "Не найдена информационная база: " + ИнформационнаяБаза;
	КонецЕсли;
	
	Возврат СтрШаблон("--infobase=%1", ОписаниеИБ.UID);
	
КонецФункции

Функция КлючИдентификатораКластераБазы(Знач ИнформационнаяБаза)

	ОписаниеИБ = ИндексИнформационныхБаз[ИнформационнаяБаза];

	Если ОписаниеИБ = Неопределено Тогда
		ВызватьИсключение "Не найдена информационная база: " + ИнформационнаяБаза;
	КонецЕсли;

	Возврат СтрШаблон("--cluster=%1", ОписаниеИБ.Кластер);
	
КонецФункции

Функция ВФильтре(Данные, Фильтр)

	Результат = ЗначениеЗаполнено(Фильтр);

	Если Не ЗначениеЗаполнено(Фильтр) Тогда
		Возврат Результат;
	КонецЕсли;

	Результат = Результат И ПараметраВФильтре(Фильтр, "Приложение", Данные.Приложение);
	Результат = Результат И ПараметраВФильтре(Фильтр, "Пользователь", Данные.Пользователь);

	Возврат Результат;
	
КонецФункции

Функция ПараметраВФильтре(Фильтр, ИмяФильтра, ПроверяемоеЗначение)
	
	Если Не ЗначениеЗаполнено(Фильтр) 
		Или Не Фильтр.Свойство(ИмяФильтра) Тогда
		Возврат Истина;
	КонецЕсли;
	
	ЗначенияФильтра = Фильтр[ИмяФильтра];
	Для Каждого ТекЗначение Из ЗначенияФильтра Цикл
		ВФильтре = ВРег(ТекЗначение)=ВРег(ПроверяемоеЗначение);
		Если ВФильтре Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;

КонецФункции

Процедура ОбновитьИндексИнформационныхБаз(Знач Кластер, Знач Принудительно = Ложь) 
	
	Если Не Принудительно 
		И Не ИндексЛокальныхКластеров[Кластер] = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Получаю список баз кластера");

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("infobase");
	Параметры.Добавить("summary");
	Параметры.Добавить("list");
	Параметры.Добавить(КлючИдентификатораКластера(Кластер));

	СписокБазВКластере = СокрЛП(ВыполнитьКоманду(Параметры));

	Данные = РазобратьПотокВывода(СписокБазВКластере);
	
	ОчиститьИндексИнформационныхБазы(Кластер);
	
	ИндексИБКластера = Новый Соответствие();

	Для Каждого Элемент Из Данные Цикл
		
		ОписаниеИБ = ОписаниеИнформационнойБазы(Элемент["name"], Элемент["infobase"], Кластер);

		Лог.Отладка("База <%1> (%2) добавлена в индекс", ОписаниеИБ.Имя,  ОписаниеИБ.UID);
		
		ИндексИнформационныхБаз.Вставить(ОписаниеИБ.Имя, ОписаниеИБ);
		ИндексИнформационныхБаз.Вставить(ОписаниеИБ.UID, ОписаниеИБ);
		ИндексИБКластера.Вставить(ОписаниеИБ.UID, ОписаниеИБ);

	КонецЦикла;

	ИндексЛокальныхКластеров[Кластер] = ИндексИБКластера;

КонецПроцедуры

Процедура ОчиститьИндексИнформационныхБазы(Знач Кластер)
	
	ИндексИБКластера = ИндексЛокальныхКластеров[Кластер];

	Если ИндексИБКластера = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Для каждого КлючЗначение Из ИндексИБКластера Цикл
		ОписаниеИБ = КлючЗначение.Значение;
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.Имя);
		ИндексИнформационныхБаз.Удалить(ОписаниеИБ.UID);
	КонецЦикла;

КонецПроцедуры

Процедура ОбновитьИндексЛокальныхКластеров()
	
	Лог.Отладка("Получаю список кластеров");
	ИндексЛокальныхКластеров = Новый Соответствие();

	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить("cluster");
	Параметры.Добавить("list");

	СписокКластеров = ВыполнитьКоманду(Параметры);
	
	Данные = РазобратьПотокВывода(СписокКластеров);

	Для Каждого Элемент Из Данные Цикл
		
		UIDКластера = Элемент["cluster"];

		Лог.Отладка("Локальный кластер <%1> добавлена в индекс", UIDКластера);
		
		ИндексЛокальныхКластеров.Вставить(UIDКластера);

	КонецЦикла;

	ИндексКластераОбновлен = Истина;

КонецПроцедуры

Функция СтрокаЗапускаКлиента()
	
	Перем ПутьКлиентаАдминистрирования;
	
	Если ЭтоWindows Тогда 
		ПутьКлиентаАдминистрирования = ОбернутьВКавычки(ПутьКлиентаАдминистрирования);
	Иначе
		ПутьКлиентаАдминистрирования = ПутьКлиентаАдминистрирования;
	КонецЕсли;
	
	Возврат ПутьКлиентаАдминистрирования;
	
КонецФункции

Функция ИспользуетсяАвторизацияКластера()

	Возврат ЗначениеЗаполнено(АвторизацияАдминистратораКластера.Пользователь);
	
КонецФункции

Функция ЕстьПараметр(ПараметрыКоманды, ИмяПараметра)
	
	Для каждого Параметр Из ПараметрыКоманды Цикл
		
		Если СтрНайти(Параметр, ИмяПараметра) > 0 Тогда
			Возврат Истина;
		КонецЕсли
	КонецЦикла;

	Возврат Ложь;

КонецФункции

Функция РазобратьПотокВывода(Знач Поток)
	
	ТД = Новый ТекстовыйДокумент;
	ТД.УстановитьТекст(Поток);
	
	СписокОбъектов = Новый Массив;
	ТекущийОбъект = Неопределено;
	
	Для Сч = 1 По ТД.КоличествоСтрок() Цикл
		
		Текст = ТД.ПолучитьСтроку(Сч);
		Если ПустаяСтрока(Текст) или ТекущийОбъект = Неопределено Тогда
			Если ТекущийОбъект <> Неопределено и ТекущийОбъект.Количество() = 0 Тогда
				Продолжить; // очередная пустая строка подряд
			КонецЕсли;
			 
			ТекущийОбъект = Новый Соответствие;
			СписокОбъектов.Добавить(ТекущийОбъект);
		КонецЕсли;
		
		СтрокаРазбораИмя      = "";
		СтрокаРазбораЗначение = "";
		
		Если РазобратьНаКлючИЗначение(Текст, СтрокаРазбораИмя, СтрокаРазбораЗначение) Тогда
			ТекущийОбъект[СтрокаРазбораИмя] = СтрокаРазбораЗначение;
		КонецЕсли;
		
	КонецЦикла;
	
	Если ТекущийОбъект <> Неопределено и ТекущийОбъект.Количество() = 0 Тогда
		СписокОбъектов.Удалить(СписокОбъектов.ВГраница());
	КонецЕсли; 
	
	Возврат СписокОбъектов;
	
КонецФункции

Функция РазобратьНаКлючИЗначение(Знач СтрокаРазбора, Ключ, Значение)
	
	ПозицияРазделителя = Найти(СтрокаРазбора, ":");
	Если ПозицияРазделителя = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Ключ     = СокрЛП(Лев(СтрокаРазбора, ПозицияРазделителя - 1));
	Значение = УбратьКавычки(СокрЛП(Сред(СтрокаРазбора, ПозицияРазделителя + 1)));
	
	Возврат Истина;
	
КонецФункции

Функция УбратьКавычки(Знач СтрокаСКавычками)
	
	СтрокаБезКавычек = СтрокаСКавычками;

	Если СтрНачинаетсяС(СтрокаСКавычками, """") Тогда
		СтрокаБезКавычек = Сред(СтрокаБезКавычек, 2);
	КонецЕсли;

	Если СтрЗаканчиваетсяНа(СтрокаСКавычками, """") Тогда
		СтрокаБезКавычек = Лев(СтрокаБезКавычек, СтрДлина(СтрокаБезКавычек) - 1);
	КонецЕсли;

	СтрокаБезКавычек = СтрЗаменить(СтрокаБезКавычек, """""", """");

	Возврат СтрокаБезКавычек;

КонецФункции

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.lib.v8rac");
	// Лог = Логирование.ПолучитьЛог("oscript.lib.commands");
	// Лог.УстановитьУровень(УровниЛога.Отладка);

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
	ИндексЛокальныхКластеровОбновлен = Ложь;
	
	АвторизацияАдминистратораКластера = Новый Структура("Пользователь, Пароль");

	ИндексИнформационныхБаз = Новый Соответствие();
	ИндексЛокальныхКластеров = Новый Соответствие();
	ИндексАвторизацийИнформационныхБаз = Новый Соответствие();

	ПутьКлиентаАдминистрирования = ПолучитьПутьКRAC("8.3");

	ИмяКлючаВсеБазы = "all";

КонецПроцедуры

#КонецОбласти
