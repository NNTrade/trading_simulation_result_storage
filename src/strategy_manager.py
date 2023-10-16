import pandas as pd
import logging
from .version_manager import VersionManager
from .connector_factory import ConnectorFactory
from .tools import columns_converter
from .constants.table import STRATEGY, STRATEGY_V


class StrategyManager:
    def __init__(self, db_connection_factory: ConnectorFactory, parent_logger: logging.Logger = None) -> None:
        self.__db_connection_factory: ConnectorFactory = db_connection_factory
        logger_name = f"StrategyManager[{db_connection_factory.dbname}]"
        self.__logger = logging.getLogger(logger_name) if parent_logger is None \
            else parent_logger.getChild(logger_name)
        pass

    def GetStrategyById(self, id: int) -> pd.Series:
        connection = self.__db_connection_factory.build()
        try:
            with connection.cursor() as cursor:
                field_list = ["s.id", "s.name", "s.description"]
                from_query = f"{STRATEGY} as s"

                cursor.execute(
                    f"SELECT {', '.join(field_list)} FROM {from_query} WHERE id = {id}")

                fetched_data = cursor.fetchone()
                return pd.Series(
                    fetched_data, index=columns_converter(field_list), name=id)
        finally:
          connection.close()

    def GetStrategies(self, load_version: bool = True) -> pd.DataFrame:
        connection = self.__db_connection_factory.build()
        try:
            with connection.cursor() as cursor:
                field_list = ["s.id", "s.name"]
                from_query = f"{STRATEGY} as s"
                if load_version:
                    field_list.extend(["sv.version", "sv.note"])
                    from_query = f"{from_query} right join {STRATEGY_V} as sv on s.id = sv.strategy_id"

                cursor.execute(
                    f"SELECT {', '.join(field_list)} FROM {from_query}")

                fetched_data = cursor.fetchall()
                return pd.DataFrame.from_records(fetched_data, columns=columns_converter(field_list)).set_index("id")
        finally:
          connection.close()

    def PostStrategy(self, name: str, description: str = "", note: str = "Init strategy") -> int:
        connection = self.__db_connection_factory.build()
        try:
          with connection:
            with connection.cursor() as cursor:
                sql = f"INSERT INTO {STRATEGY} (name, description) VALUES ('{name}', '{description}') RETURNING id"
                cursor.execute(sql)
                strategy_id = cursor.fetchone()[0]

            VersionManager.PostNewVersionInConn(
                strategy_id, 1, note, connection)

            self.__logger.info(
                "New transaction %s added with id %i", name, strategy_id)

            return strategy_id
        finally:
          connection.close()
