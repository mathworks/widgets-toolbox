// // Eventlistener for Input Sliders
// addEventListener("input", e => {
//     // Step 1: Capture Event Target
//     let _t = e.target;

//     // Step 2: Collect References to Both Slider Thumbs
//     let minSlider = document.getElementById("sliderA");
//     let maxSlider = document.getElementById("sliderB");

//     // Convert Values to Integers to allow for correct mathematical comparison
//     currentSliderValue = parseInt(_t.value);
//     minSliderValue = parseInt(minSlider.value);
//     maxSliderValue = parseInt(maxSlider.value);

//     // Step 3: Conditionally ensure no slider thumb can move past each other.
//     // Apply Logic to Min Slider (A)
//     if (_t === minSlider){
//       // Prevent Min Slider from Exceeding MaxSlider
//       if (currentSliderValue > maxSliderValue){
//         _t.value = maxSlider.value;
//       }
//     }
//     else if (_t === maxSlider){
//       // Prevent Max Slider from going past MinSlider
//       if (currentSliderValue < minSliderValue){
//         _t.value = minSlider.value;
//       }
//     }

//     // Cap Style and Display String for New Position
//     _t.parentNode.style.setProperty(`--${_t.id}`, +_t.value);

//  }, false);


// Setup JS Method - Initializes Various Callbacks for Data Property of DualSlider HTML Component
function setup(htmlComponent){

    // Add Eventlistener for Data Property of HTMLComponent
    htmlComponent.addEventListener("DataChanged",function(event){
      /// Listener Function for When Data Changes
      // Details: The Data structure carries the necessary information about the DualSlider, such as
      //          the slider thumb values and the slider range limits. When any of the data values change,
      //          we want to ensure that the values passed in from MATLAB are reflected correctly in the
      //          slider thumb appearance.
  
      // Parse incoming json-encoded struct
      htmlData = JSON.parse(htmlComponent.Data);
  
      // Get Access to both slider thumbs
      let minSlider = document.getElementById("sliderA");
      let maxSlider = document.getElementById("sliderB");
  
      // Set Slider Positions based on MATLAB Data
      minSlider.value = htmlData.LowerValue;
      maxSlider.value = htmlData.UpperValue;
  
      // Set Slider Limits based on MATLAB Data
      // Update Min Slider
      minSlider.min = htmlData.LowerLimit;
      minSlider.max = htmlData.UpperLimit
      // Update Max Slider
      maxSlider.min = htmlData.LowerLimit;
      maxSlider.max = htmlData.UpperLimit;
  
      // Trigger Repaint of CSS for Slider Positions
      const dualSlider = document.getElementById("dualSlider");
      dualSlider.style.setProperty("--sliderA",htmlData.LowerValue);
      dualSlider.style.setProperty("--sliderB",htmlData.UpperValue);
      dualSlider.style.setProperty("--min",htmlData.LowerLimit);
      dualSlider.style.setProperty("--max",htmlData.UpperLimit);
  
      // Calculate Number of Ticks
      let numTicks = (htmlData.UpperLimit - htmlData.LowerLimit) + 1;
  
      // Set CSS TickMarks Amount
      const ticks = document.getElementById("tickContent");
      ticks.style.setProperty("--numTicks",numTicks);
  
      // Update TickMarks
      createTickMarks();
  
      // Update the Label Content
      // let sliderLabelA = document.getElementById("MinLabel");
      // let sliderLabelB = document.getElementById("MaxLabel");
      // sliderLabelA.textContent = htmlData.MinLabel;
      // sliderLabelB.textContent = htmlData.MaxLabel;
  
    })
  
    // Eventlistener for Input Sliders
    addEventListener("input", e => {
      // Decompose HTML Data
      htmlData = JSON.parse(htmlComponent.Data);
  
      // Step 1: Capture Event Target
      let _t = e.target;
  
      // Step 2: Collect References to Both Slider Thumbs
      let minSlider = document.getElementById("sliderA");
      let maxSlider = document.getElementById("sliderB");
  
      // Convert Values to Integers to allow for correct mathematical comparison
      currentSliderValue = parseInt(_t.value);
      minSliderValue = parseInt(minSlider.value);
      maxSliderValue = parseInt(maxSlider.value);
  
      // Step 3: Conditionally ensure no slider thumb can move past each other.
      // Apply Logic to Min Slider (A)
      if (_t === minSlider){
        // Prevent Min Slider from Exceeding MaxSlider
        if (currentSliderValue > maxSliderValue){
          _t.value = maxSlider.value;
        }
      }
      else if (_t === maxSlider){
        // Prevent Max Slider from going past MinSlider
        if (currentSliderValue < minSliderValue){
          _t.value = minSlider.value;
        }
      }
  
      // Cap Style and Display String for New Position
      _t.parentNode.style.setProperty(`--${_t.id}`, +_t.value);
  
      // Store New Slider Values back in data
      htmlData.LowerValue = parseInt(minSlider.value);
      htmlData.UpperValue = parseInt(maxSlider.value);
      
      // Rebuild HTML Data
      htmlComponent.Data = JSON.stringify(htmlData);
  
      // Update TickMarks
      createTickMarks();
  
    }, false);
  
  
  } //function
  
  
  
  // Create Tickmarks Function
  function createTickMarks(){
    // CREATETICKMARKS - Function to dynamically generate divs for the DualSlider 
    // to properly space the TickMarks used to indicate thumb position.
  
    // Clear Container Div
    clearTickContainer();
  
    // Create Outer Edge Block #1
    createOuterEdgeSpace();
  
    // Create Ticks and Inner Spaces
    createTicksAndInnerSpaces();
  
    // Create Outer Edge Block #2
    createOuterEdgeSpace();
  
  } //function
  
  function clearTickContainer(){
    // CLEARTICKCONTAINER - Function to remove existing TickMark Divs to prepare for 
    // a redraw of tickmark color rectangles.
  
    let tickContainer = document.getElementById("tickContent");
  
    // While there is a first child, remove it. Yields no children.
    while (tickContainer.firstChild){
      tickContainer.removeChild(tickContainer.firstChild);
    } //while
  
  } //function
  
  function createOuterEdgeSpace(){
    // CREATEOUTEREDGESPACE - Function to make an outer edge space div.
    // Make Div and classify it as an edge space.
    var div = document.createElement('div');
    div.className = 'tickEdgeSpace';
  
    // Append it to the collection of Tick Divs
    document.getElementById('tickContent').appendChild(div);
  
  } //function
  
  function createTicksAndInnerSpaces(){
    // CREATETICKSANDINNERSPACES - Function to make the actual tickmark and inner space divs.
    // This is assumed to start placing tick marks right after the first outer edge space by 
    // iterating through the number of ticks.
  
    // Set CSS TickMarks Amount
    const ticks = document.getElementById("tickContent");
    let numTicks = ticks.style.getPropertyValue("--numTicks");
  
    // Iterate through # of Ticks
    for (var i = 0; i < numTicks; i++)
    {
      // Make TickMark Div and classify it as a TickMark Block
      var div = document.createElement("div");
      div.className = "tickBlock";
  
      // Append it to the collection of Tick Divs
      document.getElementById("tickContent").appendChild(div);
  
      // If we aren't on the LAST tickmark, make a Tick Inner Space
      if (i < (numTicks-1))
      {
        // Make TickMark Div and classify it as a TickMark Block
        var div = document.createElement("div");
        div.className = "tickInnerSpace";
  
        // Append it to the collection of Tick Divs
        document.getElementById("tickContent").appendChild(div);
      } //endif
  
    } //forloop
  
  } //function
  
  // 
  createTickMarks();