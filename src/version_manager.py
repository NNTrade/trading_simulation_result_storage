from .connector_factory import ConnectorFactory
from psycopg2.extensions import connection
import logging
from .constants.table import STRATEGY_V


class VersionManager:
    def __init__(self, db_connection_factory: ConnectorFactory, parent_logger: logging.Logger) -> None:
        self.__db_connection_factory: ConnectorFactory = db_connection_factory
        logger_name = f"VersionManager[{db_connection_factory.dbname}]"
        self.__logger = logging.getLogger(logger_name) if parent_logger is None \
            else parent_logger.getChild(logger_name)
        pass

    def GetLastVersionById(self, id: int) -> int:
        connection = self.__db_connection_factory.build()
        try:
          return VersionManager.GetLastVersionByIdInConn(id, connection)
        finally:
            connection.close()

    @staticmethod
    def GetLastVersionByIdInConn(id, connection: connection):
        with connection.cursor() as cursor:
            sql = f'SELECT max("version") from {STRATEGY_V} where strategy_id = {id}'
            cursor.execute(sql)
            return cursor.fetchone()[0]

    def GetLastVersionByName(self, name: str) -> int:
        connection = self.__db_connection_factory.build()
        try:
          with connection.cursor() as cursor:
              cursor.execute(
                  f'SELECT max(strategy_v."version") from {STRATEGY_V} inner join strategy on strategy.id = strategy_v.strategy_id  where strategy.name = {name}')
              return cursor.fetchone()[0]
        finally:
            connection.close()

    @staticmethod
    def PostNewVersionInConn(id: int, version: int,  note: str, connection: connection) -> int:
        last_vesion = VersionManager.GetLastVersionByIdInConn(id, connection)
        if last_vesion is None:
            if version != 1:
                raise AttributeError("First version must be 1", name="version")
        else:
            if (version - last_vesion) != 1:
                raise AttributeError(f"Posted wrong version", name="version")
        with connection.cursor() as cursor:
            cursor.execute(
                f"INSERT INTO {STRATEGY_V} (strategy_id, version, note) VALUES ({id}, {version}, '{note}') RETURNING id"
            )
            return cursor.fetchone()[0]

    def PostNewVersion(self, id: int, version: int,  note: str) -> int:
        connection = self.__db_connection_factory.build()
        try:
          with connection:
            try:
                return VersionManager.PostNewVersionInConn(id, version, note, connection)
            except AttributeError as ex:
                if ex.name == "version":
                  self.__logger.error(
                      "Try post stategy with wrong version (%i))", version)
                raise
        finally:
            connection.close()
