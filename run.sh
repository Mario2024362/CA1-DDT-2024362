#bash for the python
#for test the commands of python

echo "Running hotel booking test.."
if command -v py >/dev/null 2>&1; then
py -3.12 scripts/hotel-2024362.py
else
python3 scripts/hotel-2024362.py

