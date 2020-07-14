import boto3
import datetime
import calendar
import os
from datetime import date, datetime, timedelta

rds = boto3.client('rds')

def lambda_handler(event, context):

    dateNow = date.today()
    dayOfWeek = calendar.day_name[dateNow.weekday()]
    dbinstances = os.environ['dbinstances'].split(',')

    time = datetime.now()
    now = (time - timedelta(hours = 3))
    hour = now.hour

    print('Iniciando o lambda de schedule RDS em ' + str(dayOfWeek) + ' às ' + str(hour))

    if len(dbinstances) == 0:
        print('Nenhuma instância RDS foi cadastrada.')
        return

    if dayOfWeek == 'Saturday' or dayOfWeek == 'Sunday':
        print('Final de semana.')
        return

    if hour >= 8 and hour < 19:
        print('Iniciando as instâncias de RDS')
        
        for instance in dbinstances:
            rds.start_db_instance(DBInstanceIdentifier = instance)
    else:
        print('Parando as instâncias de RDS')
        
        for instance in dbinstances:
            rds.stop_db_instance(DBInstanceIdentifier = instance)
        
    print('Finalizando o lambda de schedule RDS.')
