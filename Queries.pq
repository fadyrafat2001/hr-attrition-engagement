// UNEXECUTED M SOURCE. Create text parameter WorkbookPath with the full local path of Synthetic_Inputs.xlsx.
// Create this function as fxSheet; every query below is a separate query, not one script.
(sheetName as text) as table =>
let
    Source = Excel.Workbook(File.Contents(WorkbookPath), null, true),
    Data = Source{[Item=sheetName, Kind="Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Data, [PromoteAllScalars=true])
in
    Headers

// Query named DimDepartment:
let
    Source = fxSheet("DimDepartment"),
    Typed = Table.TransformColumnTypes(Source, {{"DepartmentKey", Int64.Type}, {"DepartmentName", type text}, {"Division", type text}}, "en-US")
in
    Typed

// Query named DimLocation:
let
    Source = fxSheet("DimLocation"),
    Typed = Table.TransformColumnTypes(Source, {{"LocationKey", Int64.Type}, {"City", type text}, {"Country", type text}}, "en-US")
in
    Typed

// Query named DimDate:
let
    Source = fxSheet("DimDate"),
    Typed = Table.TransformColumnTypes(Source, {{"Date", type date}, {"Year", Int64.Type}, {"MonthNum", Int64.Type}, {"MonthName", type text}, {"YearMonth", type text}}, "en-US")
in
    Typed

// Query named FactEmployment (raw sheet has 3 swapped hire/leave dates, 6 engagement scores of 99 and 40 blanks):
let
    Source = fxSheet("FactEmployment"),
    Typed = Table.TransformColumnTypes(Source, {{"EmployeeID", type text}, {"DepartmentKey", Int64.Type}, {"LocationKey", Int64.Type}, {"HireDate", type date}, {"LeaveDate", type date}, {"LeaveType", type text}, {"EngagementScore", type number}, {"PerformanceRating", Int64.Type}}, "en-US"),
    HireFix = Table.AddColumn(Typed, "HireDateFix", each if [LeaveDate] <> null and [HireDate] > [LeaveDate] then [LeaveDate] else [HireDate], type date),
    LeaveFix = Table.AddColumn(HireFix, "LeaveDateFix", each if [LeaveDate] <> null and [HireDate] > [LeaveDate] then [HireDate] else [LeaveDate], type date),
    DropOld = Table.RemoveColumns(LeaveFix, {"HireDate", "LeaveDate"}),
    Renamed = Table.RenameColumns(DropOld, {{"HireDateFix", "HireDate"}, {"LeaveDateFix", "LeaveDate"}}),
    Engagement = Table.ReplaceValue(Renamed, 99, null, Replacer.ReplaceValue, {"EngagementScore"}),
    Tenure = Table.AddColumn(Engagement, "TenureYears", each Duration.Days(#date(2025, 1, 1) - [HireDate]) / 365.25, type number),
    Band = Table.AddColumn(Tenure, "TenureBand", each if [TenureYears] < 1 then "<1y" else if [TenureYears] < 3 then "1-3y" else "3y+", type text)
in
    Band
