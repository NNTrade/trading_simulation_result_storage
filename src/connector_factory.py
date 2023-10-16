import os
import psycopg2
from psycopg2.extensions import connection


class ConnectorFactory:
    def __init__(self, dbname=os.environ.get("DB_NAME"), host=os.environ.get("DB_HOST"), user=os.environ.get("TU_USER"), password=os.environ.get("TU_PWD"), port="5432") -> None:
        self.dbname = dbname
        self.host = host
        self.user = user
        self.password = password
        self.port = port
        pass

    def build(self) -> connection:
        return psycopg2.connect(dbname=self.dbname, host=self.host, user=self.user, password=self.password, port=self.port)
