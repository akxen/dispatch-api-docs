# Case file parameters
Case files submitted via the Dispatch API follow the same data structure as NEMDE case files (see [this tutorial](/tutorials/converting-a-case-file) to learn how to convert historical NEMDE case files into a format that can be consumed by the Dispatch API). This assists development efforts as historical case files provide an excellent foundation on which new features can be built. However, there are limitations that arise from this approach. For instance, the Dispatch API only uses a subset of the data contained within historical case files when formulating a mathematical program. Ambiguities may also arise when inspecting case files as some parameters are duplicated while others may be ignored. The following sections seek to address these ambiguities by explicitly outlining the parameters used when formulating a mathematical program via the Dispatch API. Updates made to these parameters will be reflected in the formulated model, while changes to all other parameters are ignored and will have no effect. 

Paths to parameters within a JSON case file document are provided. Filters may need to be used when referencing specific elements (e.g. to identify a specific trader, interconnector, region, or constraint). Where practical, tables are used to summarise possible values for these query parameters. Note that this document may be updated over time as additional information is incorporated into the model used by the Dispatch API.


## Case

```python
NEMSPDCaseFile.NemSpdInputs.Case.@VoLL
NEMSPDCaseFile.NemSpdInputs.Case.@EnergyDeficitPrice
NEMSPDCaseFile.NemSpdInputs.Case.@EnergySurplusPrice
NEMSPDCaseFile.NemSpdInputs.Case.@RampRatePrice
NEMSPDCaseFile.NemSpdInputs.Case.@InterconnectorPrice
NEMSPDCaseFile.NemSpdInputs.Case.@CapacityPrice
NEMSPDCaseFile.NemSpdInputs.Case.@OfferPrice
NEMSPDCaseFile.NemSpdInputs.Case.@TieBreakPrice
NEMSPDCaseFile.NemSpdInputs.Case.@MNSPOfferPrice
NEMSPDCaseFile.NemSpdInputs.Case.@MNSPRampRatePrice
NEMSPDCaseFile.NemSpdInputs.Case.@MNSPCapacityPrice
NEMSPDCaseFile.NemSpdInputs.Case.@FastStartPrice
NEMSPDCaseFile.NemSpdInputs.Case.@UIGFSurplusPrice
NEMSPDCaseFile.NemSpdInputs.Case.@ASMaxAvailPrice
NEMSPDCaseFile.NemSpdInputs.Case.@ASEnablementMinPrice
NEMSPDCaseFile.NemSpdInputs.Case.@ASEnablementMaxPrice
NEMSPDCaseFile.NemSpdInputs.Case.@FastStartThreshold
```

## Regions

### Initial conditions

```python
NEMSPDCaseFile.NemSpdInputs.RegionCollection.Region[?(@RegionID="region_id")].RegionInitialConditionCollection.RegionInitialCondition[?(@InitialConditionID="initial_condition_id"})].@Value
```

| region_id | Description |
| :-------- | :---------- |
| SA1 | South Australia |
| VIC1 | Victoria |
| TAS1 | Tasmania |
| NSW1 | New South Wales |
| QLD1 | Queensland |

| initial_condition_id | Description |
| :-------- | :---------- |
| ADE | Aggregate dispatch error at start of dispatch interval (MW) |
| InitialDemand | Demand at start of dispatch interval (MW) |

### Demand Forecast
The Demand Forecast (`@DF`) parameter denotes the difference between anticipated region demand at the end of the dispatch interval and region demand at the start of the interval. For example, if `@DF=20` it indicates demand is expected to be 20MW higher at the end of the interval relative to the start of the interval.

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.RegionPeriodCollection.RegionPeriod[?(@RegionID="region_id")].@DF
```

## Traders
### Metadata
From TraderCollection:

```python
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@TraderID
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@TraderType
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@SemiDispatch
```

| Key | Description |
| :------ | :---------- |
| @TraderID | Unique trader ID. Same as Dispatchable Unit Identifier (DUID). |
| @TraderType | Either "GENERATOR", "LOAD", or "NORMALLY_ON_LOAD" |
| @SemiDispatch | Flag indicating if unit is semi-dispatchable. "1"=semi-dispatchable unit (e.g. wind / solar), "0"=dispatchable unit |

From TraderPeriodCollection:

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].@RegionID
```

| Key | Description |
| :------ | :---------- |
| @RegionID | Region in which trader is located |

### Initial conditions

```python
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TraderInitialConditionCollection.TraderInitialCondition[?(@InitialConditionID="initial_condition_id")].@Value
```

| initial_condition_id | Description |
| :-------- | :---------- |
| AGCStatus | Unit AGC status ('1'=AGC enabled, '0'=AGC disabled) |
| HMW | Max output from SCADA telemetry (MW) |
| InitialMW | Trader output at start of dispatch interval (MW) |
| LMW | Min output from SCADA telemetry (MW) |
| WhatIfInitialMW | Trader initial MW value to use if intervention pricing run (MW) |
| SCADARampDnRate | Max ramp down rate reported by SCADA telemetry (MW/hour) |
| SCADARampUpRate | Max ramp up rate reported by SCADA telemetry (MW/hour) |


### Price bands

```python
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@TradeType
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand1
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand2
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand3
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand4
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand5
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand6
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand7
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand8
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand9
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].TradePriceStructureCollection.TradePriceStructure.[?(@TradeType="trade_type")].@PriceBand10
```

| trade_type | Description |
| :-------- | :---------- |
| ENOF | Generator energy market offer |
| LDOF | Load energy market offer |
| R6SE | Contingency FCAS raise 6s offer |
| R60S | Contingency FCAS raise 60s offer |
| R5MI | Contingency FCAS raise 5min offer |
| R5RE | Regulation FCAS raise offer |
| L6SE | Contingency FCAS lower 6s offer |
| L60S | Contingency FCAS lower 60s offer |
| L5MI | Contingency FCAS lower 5min offer |
| L5RE | Regulation FCAS lower offer |


### Quantity bands
Quantity bands and max availability for a given @TradeType:

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@TradeType
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@MaxAvail
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail1
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail2
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail3
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail4
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail5
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail6
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail7
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail8
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail9
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@BandAvail10
```

Ramp rate parameters must be included for energy market offers (i.e. @TradeType is either ENOF or LDOF):

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@RampUpRate
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@RampDnRate
```

FCAS trapezium parameters must be included for FCAS offers (i.e. @TradeType is in [R6SE, R60S, R6MI, R5RE, L6SE, L60S, L5MI, L5RE]):

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@EnablementMin
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@EnablementMax
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@LowBreakpoint
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].TradeCollection.Trade[@TradeType="trade_type"].@HighBreakpoint
```

###  UIGF
The Unconstrained Intermittent Generation Forecast (UIGF) is defined for semi-scheduled units. The parameter denotes a unit's forecast max power output at the end of a dispatch interval.

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.TraderPeriodCollection.TraderPeriod[?(@TraderID="trader_id")].@UIGF
```

### Fast-start unit parameters
The following parameters describe the inflexibility profile fast-start units are subject to once they come online.

```python
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@FastStart
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@MinLoadingMW
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@CurrentMode
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@CurrentModeTime
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@T1
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@T2
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@T3
NEMSPDCaseFile.NemSpdInputs.TraderCollection.Trader[?(@TraderID="trader_id")].@T4
```

## Interconnectors

### Metadata

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@InterconnectorID
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@MNSP
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@FromRegion
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@ToRegion
```

| Key | Description |
| :--- | : -------- |
| @InterconnectorID | Unique identifier for interconnector |
| @MNSP | Flag indicating if interconnector is a Market Network Service Provider (MNSP). "1"=is a MNSP, "0"=not an MNSP. |
| @FromRegion | Interconnector's notional 'from' region |
| @ToRegion | Interconnector's notional 'to' region |

| interconnector_id | Name |
| :---------------- | :---------- |
| N-Q-MNSP1 | Terranora |
| NSW1-QLD1 | New South Wales to Queensland |
| VIC1-NSW1 | Victoria to New South Wales |
| T-V-MNSP1 | Basslink |
| V-SA | Heywood |
| V-S-MNSP1 | Murraylink |

Interconnectors connect NEM regions. The @FromRegion and @ToRegion parameters define the direction of positive power flow over the interconnector. A net transfer out of @FromRegion into @ToRegion results in a positive flow value, while negative values correspond to a net transfer out of @ToRegion into @FromRegion.

### Power flow limits

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@LowerLimit
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@UpperLimit
```

| Key | Description |
| :--- | :--------- |
| @LowerLimit | Max flow in the direction @ToRegion &#8594; @FromRegion (MW) |
| @UpperLimit | Max flow in the direction @FromRegion &#8594; @ToRegion (MW) |

### Initial conditions

```python
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].InterconnectorInitialConditionCollection.InterconnectorInitialCondition[?(@InitialConditionID="initial_condition_id")].@Value
```
                        
| initial_condition_id | Description |
| :-------- | :---------- |
| InitialMW | Power flow over interconnector at start of dispatch interval (MW) |
| WhatIfInitialMW | Initial power flow value to use if intervention pricing run (MW) |

### Loss model

```python
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].LossModelCollection.LossModelCollection.@LossLowerLimit
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].LossModelCollection.LossModelCollection.@LossShare
```

| Key | Description |
| :--- | :--------- |
| @LossLowerLimit | Left most edge of loss function curve (MW) |
| @LossShare | Interconnector losses are allocated to @FromRegion and @ToRegion in proportion to @LossShare. @LossShare denotes the proportion of interconnector losses assigned to @FromRegion. (1 - @LossShare) x InterconnectorLoss is assigned to @ToRegion. |

The interconnector loss model uses a piecewise linear function to describe interconnector losses as a function of interconnector power flow. Loss model segments denote marginal losses for each interval of the piecewise linear function.

```python
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].LossModelCollection.LossModelCollection.SegmentCollection.Segment[n].@Limit
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].LossModelCollection.LossModelCollection.SegmentCollection.Segment[n].@Factor
```

| Key | Description |
| :------- | :---------- |
| @Limit | Power flow value at right edge of segment bin (MW) |
| @Factor | Marginal loss over segment |


<!-- #### Basslink loss model parameters -->
<!-- Additional parameters defined for T-V-MNSP1: -->

<!-- ```
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].@FromRegionLF
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].@ToRegionLF
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].@FromRegionLFImport
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].@FromRegionLFExport
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].@ToRegionLFImport
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].@ToRegionLFExport
``` -->

### Basslink
Market network service providers submit offers into the market for energy much like traders. Offers are made in the @FromRegion and @ToRegion for the interconnector.

#### Price bands

```python
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@RegionID
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand1
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand2
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand3
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand4
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand5
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand6
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand7
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand8
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand9
NEMSPDCaseFile.NemSpdInputs.InterconnectorCollection.Interconnector[?(@InterconnectorID="interconnector_id"].MNSPPriceStructureCollection.MNSPPriceStructure.MNSPRegionPriceStructureCollection.MNSPRegionPriceStructure[?(@RegionID="region_id")].@PriceBand10
```

#### Quantity bands

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@RegionID
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail1
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail2
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail3
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail4
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail5
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail6
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail7
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail8
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail9
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@BandAvail10
```

#### Ramp rates and max availability

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@MaxAvail
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@RampUpRate
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].MNSPOfferCollection.MNSPOffer[?(@RegionID="region_id")].@RampDnRate
```

| Key | Description |
| :--- | :--------- |
| @MaxAvail | Max offer quantity (MW) |
| @RampUpRate | Max ramp up rate (MW/hr) |
| @RampDnRate | Max ramp down rate (MW/hr) |

#### Additional loss model parameters
<!-- NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@FromRegionLF -->
<!-- NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@ToRegionLF -->

In addition to losses arising from power flow over the interconnector, there are also losses associated with power flow between the MNSP's connection points and their correspoding regional reference nodes. These marginal loss factors depend on the direction of power flow, with different factors used if the interconnector is importing or exporting power.

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@FromRegionLFImport
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@FromRegionLFExport
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@ToRegionLFImport
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.InterconnectorPeriodCollection.InterconnectorPeriod[?(@InterconnectorID="interconnector_id")].@ToRegionLFExport
```

## Generic constraints
### Metadata
From GenericConstraintCollection:

```python
NEMSPDCaseFile.NemSpdInputs.GenericConstraintCollection.GenericConstraint[?(@ConstraintID="constraint_id")].@ConstraintID
NEMSPDCaseFile.NemSpdInputs.GenericConstraintCollection.GenericConstraint[?(@ConstraintID="constraint_id")].@Type
NEMSPDCaseFile.NemSpdInputs.GenericConstraintCollection.GenericConstraint[?(@ConstraintID="constraint_id")].@ViolationPrice
```

| Key | Description |
| :--- | :--------- |
| @ConstraintID | Unique constraint ID |
| @Type | Type of constraint. Either "LE" (less than or equal to <=), "GE" (greater than or equal to >=), or "EQ" (equality constraint ==). |
| @ViolationPrice | Constraint violation price |

### Intervention indicator
<!-- During market intervention periods AEMO may envoke constraints that distort pricing outcomes in order to ensure the system operates safely. For instance, a generator may be directed to produce above a minimum output level. By adding generic constraints NEMDE can be forced to produce the desired dispatch outcome.  -->

The @Intervention flag denotes whether a constraint is associated with an intervention interval, or if it is a regular generic constraint ("1"=intervention constraint, "0"=regular generic constraint). While all generic constraints are used to identify dispatch targets, only constraints with @Intervention="0" are used when undertaking the pricing run for the intervention interval.

```python
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.GenericConstraintPeriodCollection.GenericConstraintPeriod[?(@ConstraintID="constraint_id")].@ConstraintID
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.GenericConstraintPeriodCollection.GenericConstraintPeriod[?(@ConstraintID="constraint_id")].@Intervention
```

### Left-hand side (LHS) factor collection
The LHS of a generic constraint can consist of trader, region, and interconnector variables.

```python
NEMSPDCaseFile.NemSpdInputs.GenericConstraintCollection.GenericConstraint[?(@ConstraintID="constraint_id")].LHSFactorCollection.TraderFactor
NEMSPDCaseFile.NemSpdInputs.GenericConstraintCollection.GenericConstraint[?(@ConstraintID="constraint_id")].LHSFactorCollection.RegionFactor
NEMSPDCaseFile.NemSpdInputs.GenericConstraintCollection.GenericConstraint[?(@ConstraintID="constraint_id")].LHSFactorCollection.InterconnectorFactor
```

Example trader factors:

```python
"TraderFactor": {
    "@Factor": "1",
    "@TradeType": "ENOF",
    "@TraderID": "LK_ECHO"
}
```

Example interconnector factors:

```python
"InterconnectorFactor": {
    "@Factor": "1",
    "@InterconnectorID": "V-S-MNSP1"
}
```

Example region factors:

```python
"RegionFactor": [
    {
        "@Factor": "1",
        "@TradeType": "R5MI",
        "@RegionID": "NSW1"
    },
    ...,
]
```

### Right-hand side (RHS)
<span style="color:red">This is parameter is obtained from NEMDE outputs. This is a limitation of the Dispatch API, as the NEMDE uses SCADA values to compute RHS values. Functionality to compute RHS values from SCADA values is under active development.</span>

```python
NEMSPDCaseFile.NemSpdOutputs.ConstraintSolution[?(@ConstraintID="constraint_id" && @Intervention="intervention")].@RHS
```
