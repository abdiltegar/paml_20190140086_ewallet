import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paml_20190140086_ewallet/domain/helpers/date_formatter.dart';
import 'package:paml_20190140086_ewallet/domain/interactors/firebase/report/report_interactor.dart';
import 'package:paml_20190140086_ewallet/domain/interactors/firebase/transaction/transaction_interactor.dart';
import 'package:paml_20190140086_ewallet/domain/interactors/firebase/user/user_interactor.dart';
import 'package:paml_20190140086_ewallet/domain/models/report/report_model.dart';
import 'package:paml_20190140086_ewallet/domain/models/transaction/transaction_model.dart';
import 'package:paml_20190140086_ewallet/domain/models/user/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeRepository {
  final TransactionInteractor transactionInteractor = TransactionInteractor();
  final ReportInteractor reportInteractor = ReportInteractor();
  final UserInteractor userInteractor = UserInteractor();

  Future<List<TransactionModel>> get () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return transactionInteractor.getByIsIncome(prefs.getString('uid')!, true);
  }

  Future add(TransactionModel payload) async {
    DateFormatter dateFormatter = DateFormatter();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final data = TransactionModel(
      id: "", 
      userId: prefs.getString('uid')!, 
      amount: payload.amount, 
      isIncome: payload.isIncome, 
      trxDate: payload.trxDate, 
      description: payload.description
    );

    debugPrint("data incom to be send to interactor");

    final newIncome = <String, dynamic>{
      'user_id': data.userId,
      'amount': data.amount,
      'description': data.description,
      'is_income': data.isIncome,
      'trx_date': data.trxDate
    };

    // Update || Add daily report's amount
    
    var dailyReport = await reportInteractor.getByDate(data.userId, dateFormatter.dateFormatYMD(data.trxDate));
    if(dailyReport != null){ // if report at data.date is not empty , update the amount
      int updatedAmount = data.isIncome ? dailyReport.amount + data.amount : dailyReport.amount - data.amount;
      int incomeAmount = data.isIncome ? dailyReport.income + data.amount : dailyReport.income;
      int outcomeAmount = data.isIncome ? dailyReport.outcome : dailyReport.outcome + data.amount;

      var updatedReport = <String, dynamic>{
        'user_id': data.userId,
        'date': dateFormatter.dateFormatYMD(data.trxDate),
        'amount': updatedAmount,
        'income': incomeAmount,
        'outcome': outcomeAmount
      };

      await reportInteractor.update(dailyReport.id, updatedReport);
    } else {// if report at data.date is empty , add new report
      int incomeAmount = data.isIncome ? data.amount : 0;
      int outcomeAmount = data.isIncome ? 0 : data.amount;

      var newReport = <String, dynamic>{
        'user_id': data.userId,
        'date': dateFormatter.dateFormatYMD(data.trxDate),
        'amount': data.amount,
        'income': incomeAmount,
        'outcome': outcomeAmount
      };

      await reportInteractor.add(newReport);
    }

    // Update user's balance
    var user = await userInteractor.get(prefs.getString('uid')!, prefs.getString('email')!);
    if(user != null){
      int balance = data.isIncome ? user.balance + data.amount : user.balance - data.amount;
      var updatedUser = <String, dynamic>{
        'uid': user.uid, 
        'name': user.name,
        'balance': balance
      };

      await userInteractor.update(user.id, updatedUser);
    }

    return await transactionInteractor.add(newIncome);
  }

  Future edit(TransactionModel data) async {
    DateFormatter dateFormatter = DateFormatter();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final updatedIncome = <String, dynamic>{
      'user_id': data.userId,
      'amount': data.amount,
      'description': data.description,
      'is_income': data.isIncome,
      'trx_date': data.trxDate
    };

    var prevIncome = await transactionInteractor.getById(data.id);
    if(prevIncome == null){
      return false;
    }

    var dailyReport = await reportInteractor.getByDate(data.userId, dateFormatter.dateFormatYMD(data.trxDate));
    if(dailyReport != null){ // if report at data.date is not empty , update the amount
      int updatedAmount = data.isIncome ? (dailyReport.amount - prevIncome.amount) + data.amount : (dailyReport.amount - prevIncome.amount) - data.amount;
      int incomeAmount = data.isIncome ? (dailyReport.income - prevIncome.amount) + data.amount : dailyReport.income;
      int outcomeAmount = data.isIncome ? dailyReport.outcome : (dailyReport.outcome - prevIncome.amount) + data.amount;

      var updatedReport = <String, dynamic>{
        'user_id': data.userId,
        'date': dateFormatter.dateFormatYMD(data.trxDate),
        'amount': updatedAmount,
        'income': incomeAmount,
        'outcome': outcomeAmount
      };

      await reportInteractor.update(dailyReport.id, updatedReport);
    } else {// if report at data.date is empty , add new report
      int incomeAmount = data.isIncome ? data.amount : 0;
      int outcomeAmount = data.isIncome ? 0 : data.amount;

      var newReport = <String, dynamic>{
        'user_id': data.userId,
        'date': dateFormatter.dateFormatYMD(data.trxDate),
        'amount': data.amount,
        'income': incomeAmount,
        'outcome': outcomeAmount
      };

      await reportInteractor.add(newReport);
    }

    // Update user's balance
    var user = await userInteractor.get(prefs.getString('uid')!, prefs.getString('email')!);
    if(user != null){
      int balance = data.isIncome ? (user.balance - prevIncome.amount) + data.amount : (user.balance + prevIncome.amount) - data.amount;
      var updatedUser = <String, dynamic>{
        'uid': user.uid, 
        'name': user.name,
        'balance': balance
      };

      await userInteractor.update(user.id, updatedUser);
    }
    
    return await transactionInteractor.update(data.id,updatedIncome);
  }

  Future delete(String id) async {
    DateFormatter dateFormatter = DateFormatter();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = await transactionInteractor.getById(id);
    if(data == null){
      return false;
    }

    var dailyReport = await reportInteractor.getByDate(data.userId, dateFormatter.dateFormatYMD(data.trxDate));
    if(dailyReport != null){ // if report at data.date is not empty , update the amount
      int updatedAmount = data.isIncome ? dailyReport.amount - data.amount : dailyReport.amount +  data.amount;
      int incomeAmount = data.isIncome ? dailyReport.income - data.amount : dailyReport.income;
      int outcomeAmount = data.isIncome ? dailyReport.outcome : dailyReport.outcome - data.amount;

      var updatedReport = <String, dynamic>{
        'user_id': data.userId,
        'date': dateFormatter.dateFormatYMD(data.trxDate),
        'amount': updatedAmount,
        'income': incomeAmount,
        'outcome': outcomeAmount
      };

      await reportInteractor.update(dailyReport.id, updatedReport);
    }

    // Update user's balance
    var user = await userInteractor.get(prefs.getString('uid')!, prefs.getString('email')!);
    if(user != null){
      int balance = data.isIncome ? user.balance - data.amount : user.balance +  data.amount;
      var updatedUser = <String, dynamic>{
        'uid': user.uid, 
        'name': user.name,
        'balance': balance
      };

      await userInteractor.update(user.id, updatedUser);
    }
    
    return await transactionInteractor.delete(data.id);
  }
}