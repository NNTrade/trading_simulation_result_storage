from typing import List


def columns_converter(select_col_list: List[str]) -> List[str]:
  return [s.split(".")[1] for s in select_col_list]
