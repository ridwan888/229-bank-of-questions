//global variables for different functionalities
var data;
var tags = '';
var topics = new Array;
function generateRow(item) {
    /* this fucntion renders a row in the table, 
    it takes a data item as input and returns an html row as string
     */
    if (item['Appeared']) {
        var tag_string = '';
        if (item['Tags']) {
            tag_string = item['Tags'].replace(',', ' ');
        };
        return '<tr> \
                    <td> \
                        <em class="question ' + tag_string + '"></em><a href="' + item['Solution'].replace('-sol', '') + '">' + item['Name'] + '</a> \
                    </td> \
                    <td> \
                        ' + item['Appeared'] + ' \
                    </td> \
                    <td> \
                        <a href="' + item['Solution'] + '">' + item['Solution'] + '</a> \
                    </td> \
                </tr>'
    } else {
        topics.push(item);
        return '<tr>\
                    <td scope="row">\
                        <b><a name="' + item['Name'].replace(' ', '_') + '"> ' + item['Name'] + '</a> </b>\
                    </td> <td> </td> <td> </td>\
                </tr>'
    }
};


function filterByTags(data, tags) {
    /* this function takes in data array and a tags array and returns the filterd array with given tags 
     */
    if (tags.length < 1){
        return data;
    };
    var filteredData = new Array;
    var regex = new RegExp(tags.join('|'));
    data.forEach(function(item) {
        if (item['Tags']) {
            if (item['Tags'].match(regex)) {
                filteredData.push(item);
            };
        }
    });
    return filteredData;
};

function filterBySearchTerms(data, text) {
    /* this function takes in data array and a search string and returns the filterd array 
        by performing regex text matches. 
        Each keyword would be taken by separating the stirng by ` ` from it's lower case values
        eg: 'An Example String' -> 'an example string' -> [An, Example, String] 
        regex: /an/example/string/
     */
    var filteredData = new Array;
    var terms = text.toLowerCase().split(' ');
    var regex = new RegExp(terms.join('|'));
    data.forEach(function(item) {
        if (item['Appeared']) {
            if (item['Name'].toLowerCase().match(regex)) {
                filteredData.push(item);
            };
        }
    });
    return filteredData;
};

function renderTopics(topics) {
    // this function adds each topic to html list
    topics.forEach(function(item) {
        $('#topics').append('<li> <b> <a href="#' + item['Name'].replace(' ', '_') + '">' + item['Name'] + '</a> </b></li>');
    });

};

function getSelectedTags(){
    var st = new Array;
    $("input[name='tags']:checked").each(function (index, obj) {
        st.push(obj.value)
    });
    return st;
}

function renderTable(data) {
    // this funtion generates the html table
    success: $('#qtable').empty();
    success: $('#qtable').append('<thead>\
                <tr>\
                    <td scope="col">\
                        <b> </b>\
                    </td>\
                    <td scope="col">\
                        <b> Appeared </b>\
                    </td>\
                    <td scope="col">\
                        <b> Solution </b>\
                    </td>\
                </tr>\
            </thead>')
    success: $('#qtable').append('<tbody> </tbody>');
    data.forEach(function(item) {
        if (item['Name']) {
            $('#qtable tbody').append(generateRow(item));
        };
    });
};

Papa.parse('./static/229-bank-of-questions.csv', {
    header: true,
    download: true,
    dynamicTyping: true,
    complete: function(results) {
        //run this code on completation of papa parser
        data = results.data;
        // success: will make it wait untill function call finishes  
        success: renderTable(data);
        renderTopics(topics);
        // extract tags from data table
        success: data.forEach(function(item) {
            if (item['Tags']) {
                // replace any space in tag string
                tStr = item['Tags'].replace(/\s/g, "") + ',';
                tags += tStr;
            };
        });

        // split the tags by `,` and create a set and an array from the set
        success: tags = Array.from(new Set(tags.split(','))).sort();

        // for each tag in tags array add a button
        success: tags.forEach(function(tag) {
            if (tag) {
                
                $('.tag-boxes').append('<div class="checkbox-inline"><input type="checkbox" name="tags" value="'+ tag +'"> <span>'+ tag+' </span></div>');
            };
        });

        //Add a filter button
        $('.tag-btns').append('<button type="button" id="filter" class="btn btn-secondary tag-btn">Filter</button>');
        // Add show all button at the end
        $('.tag-btns').append('<button type="button" id="all" class="btn btn-secondary tag-btn">Clear</button>');

        //event handler for tags button press
        $('.tag-btn').click(function(item) {
                if (this.id === 'all') {
                    $('#search-box').val('');
                    $('input:checkbox').removeAttr('checked');
                    renderTable(data)
            } else if (this.id === 'filter'){
                $('#search-box').val('');
                renderTable(filterByTags(data, getSelectedTags()))
            }
            
        });

        //event handlers for search
        $('.search').click(function() {
            var filteredData = data;
            var terms = $('#search-box').val();
            if ( getSelectedTags().length > 0) {
                filteredData = filterByTags(filteredData,  getSelectedTags());
            };
            if (terms.length > 0) {
                filteredData = filterBySearchTerms(filteredData, terms);
            };
            renderTable(filteredData);
        });

    }
});