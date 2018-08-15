module.exports = async function isError(error) {
    const str = error.toString();
    return str.includes('revert');
}

module.exports = async function assertError(error) {
    assert.isTrue(isError(error));
}